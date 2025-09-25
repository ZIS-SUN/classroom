package com.seatreservation.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.seatreservation.dto.ReservationRequest;
import com.seatreservation.entity.Reservation;
import com.seatreservation.entity.Seat;
import com.seatreservation.entity.SeatType;
import com.seatreservation.entity.User;
import com.seatreservation.entity.PaymentRecord;
import com.seatreservation.mapper.ReservationMapper;
import com.seatreservation.mapper.SeatMapper;
import com.seatreservation.mapper.SeatTypeMapper;
import com.seatreservation.mapper.UserMapper;
import com.seatreservation.service.ReservationService;
import com.seatreservation.vo.ReservationVO;
import com.seatreservation.mapper.PaymentRecordMapper;
import com.seatreservation.service.PaymentService;
import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

@Slf4j
@Service
public class ReservationServiceImpl extends ServiceImpl<ReservationMapper, Reservation> implements ReservationService {

    @Autowired
    private ReservationMapper reservationMapper;

    @Autowired
    private SeatMapper seatMapper;

    @Autowired
    private SeatTypeMapper seatTypeMapper;

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private PaymentRecordMapper paymentRecordMapper;

    @Autowired
    private PaymentService paymentService;

    @Override
    @Transactional
    public ReservationVO createReservation(Long userId, ReservationRequest request) {
        // 验证用户存在
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new RuntimeException("用户不存在");
        }

        // 验证座位存在且可用
        Seat seat = seatMapper.selectById(request.getSeatId());
        if (seat == null) {
            throw new RuntimeException("座位不存在");
        }
        if (!"AVAILABLE".equals(seat.getStatus())) {
            throw new RuntimeException("座位不可用");
        }

        // 检查时间段冲突
        LambdaQueryWrapper<Reservation> conflictWrapper = new LambdaQueryWrapper<>();
        conflictWrapper.eq(Reservation::getSeatId, request.getSeatId())
                .eq(Reservation::getReservationDate, request.getReservationDate())
                .in(Reservation::getStatus, "UNPAID", "RESERVED", "USING")
                .and(wrapper -> wrapper
                        .lt(Reservation::getStartTime, request.getEndTime())
                        .gt(Reservation::getEndTime, request.getStartTime()));
        
        if (reservationMapper.selectCount(conflictWrapper) > 0) {
            throw new RuntimeException("该时间段座位已被预约");
        }

        // 检查用户是否有同一时间段的其他预约
        LambdaQueryWrapper<Reservation> userConflictWrapper = new LambdaQueryWrapper<>();
        userConflictWrapper.eq(Reservation::getUserId, userId)
                .eq(Reservation::getReservationDate, request.getReservationDate())
                .in(Reservation::getStatus, "UNPAID", "RESERVED", "USING")
                .and(wrapper -> wrapper
                        .lt(Reservation::getStartTime, request.getEndTime())
                        .gt(Reservation::getEndTime, request.getStartTime()));

        if (reservationMapper.selectCount(userConflictWrapper) > 0) {
            throw new RuntimeException("您在该时间段已有其他预约");
        }

        // 获取座位类型计算费用
        SeatType seatType = seatTypeMapper.selectById(seat.getSeatTypeId());
        if (seatType == null) {
            throw new RuntimeException("座位类型不存在");
        }

        // 计算预约时长和费用
        Duration duration = Duration.between(request.getStartTime(), request.getEndTime());
        double hours = duration.toMinutes() / 60.0;
        BigDecimal totalFee = seatType.getHourlyRate().multiply(BigDecimal.valueOf(hours));

        // 创建预约记录
        Reservation reservation = new Reservation();
        reservation.setUserId(userId);
        reservation.setSeatId(request.getSeatId());
        reservation.setReservationDate(request.getReservationDate());
        reservation.setStartTime(request.getStartTime());
        reservation.setEndTime(request.getEndTime());
        // 初始状态为未支付，支付成功后转为 RESERVED
        reservation.setStatus("UNPAID");
        reservation.setTotalFee(totalFee);
        reservation.setRemark(request.getRemark());
        reservation.setCreatedTime(LocalDateTime.now());
        reservation.setUpdatedTime(LocalDateTime.now());

        reservationMapper.insert(reservation);

        return buildReservationVO(reservation);
    }

    @Override
    @Transactional
    public void cancelReservation(Long userId, Long reservationId) {
        Reservation reservation = reservationMapper.selectById(reservationId);
        if (reservation == null) {
            throw new RuntimeException("预约不存在");
        }

        if (!reservation.getUserId().equals(userId)) {
            throw new RuntimeException("无权限操作该预约");
        }

        if (!"UNPAID".equals(reservation.getStatus()) && !"RESERVED".equals(reservation.getStatus())) {
            throw new RuntimeException("预约状态无法取消");
        }

        // 检查是否可以取消（预约开始前30分钟内不能取消）
        LocalDateTime reservationDateTime = LocalDateTime.of(
                reservation.getReservationDate(), 
                reservation.getStartTime()
        );
        LocalDateTime cancelDeadline = reservationDateTime.minusMinutes(30);
        
        if (LocalDateTime.now().isAfter(cancelDeadline)) {
            throw new RuntimeException("预约开始前30分钟内不能取消");
        }

        // 如已支付则自动退款
        if ("RESERVED".equals(reservation.getStatus())) {
            QueryWrapper<PaymentRecord> query = new QueryWrapper<>();
            query.eq("reservation_id", reservationId)
                 .eq("payment_status", "SUCCESS")
                 .orderByDesc("created_time")
                 .last("limit 1");
            PaymentRecord record = paymentRecordMapper.selectOne(query);
            if (record != null && reservation.getTotalFee() != null) {
                try {
                    paymentService.refund(record.getOrderNo(), reservation.getTotalFee(), "用户取消预约自动退款");
                } catch (Exception ex) {
                    log.error("取消预约退款失败: reservationId={}, error={}", reservationId, ex.getMessage());
                }
            }
        }

        reservation.setStatus("CANCELLED");
        reservation.setUpdatedTime(LocalDateTime.now());
        reservationMapper.updateById(reservation);
    }

    @Override
    @Transactional
    public void checkIn(Long userId, Long reservationId) {
        Reservation reservation = reservationMapper.selectById(reservationId);
        if (reservation == null) {
            throw new RuntimeException("预约不存在");
        }

        if (!reservation.getUserId().equals(userId)) {
            throw new RuntimeException("无权限操作该预约");
        }

        if (!"RESERVED".equals(reservation.getStatus())) {
            throw new RuntimeException("预约状态无法签到");
        }

        // 检查签到时间是否合理（预约开始时间前15分钟到预约开始时间后30分钟内）
        LocalDateTime reservationStart = LocalDateTime.of(
                reservation.getReservationDate(), 
                reservation.getStartTime()
        );
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime checkInStart = reservationStart.minusMinutes(15);
        LocalDateTime checkInEnd = reservationStart.plusMinutes(30);

        if (now.isBefore(checkInStart)) {
            throw new RuntimeException("签到时间未到，请在预约开始前15分钟内签到");
        }
        if (now.isAfter(checkInEnd)) {
            throw new RuntimeException("签到时间已过，请在预约开始后30分钟内签到");
        }

        reservation.setStatus("USING");
        reservation.setCheckInTime(now);
        reservation.setUpdatedTime(now);
        reservationMapper.updateById(reservation);
    }

    @Override
    @Transactional
    public void checkOut(Long userId, Long reservationId) {
        Reservation reservation = reservationMapper.selectById(reservationId);
        if (reservation == null) {
            throw new RuntimeException("预约不存在");
        }

        if (!reservation.getUserId().equals(userId)) {
            throw new RuntimeException("无权限操作该预约");
        }

        if (!"USING".equals(reservation.getStatus())) {
            throw new RuntimeException("预约状态无法签退");
        }

        LocalDateTime now = LocalDateTime.now();
        reservation.setStatus("COMPLETED");
        reservation.setCheckOutTime(now);
        reservation.setUpdatedTime(now);
        reservationMapper.updateById(reservation);
    }

    @Override
    public IPage<ReservationVO> getUserReservations(Long userId, Page<Reservation> page) {
        LambdaQueryWrapper<Reservation> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(Reservation::getUserId, userId)
                .orderByDesc(Reservation::getCreatedTime);

        IPage<Reservation> reservationPage = reservationMapper.selectPage(page, wrapper);
        
        // 转换为VO
        List<ReservationVO> voList = new ArrayList<>();
        for (Reservation reservation : reservationPage.getRecords()) {
            voList.add(buildReservationVO(reservation));
        }

        Page<ReservationVO> voPage = new Page<>(page.getCurrent(), page.getSize(), reservationPage.getTotal());
        voPage.setRecords(voList);
        
        return voPage;
    }

    @Override
    public ReservationVO getReservationDetail(Long userId, Long reservationId) {
        Reservation reservation = reservationMapper.selectById(reservationId);
        if (reservation == null) {
            throw new RuntimeException("预约不存在");
        }

        if (!reservation.getUserId().equals(userId)) {
            throw new RuntimeException("无权限查看该预约");
        }

        return buildReservationVO(reservation);
    }

    @Override
    public IPage<ReservationVO> getAllReservations(Page<Reservation> page, String status) {
        LambdaQueryWrapper<Reservation> wrapper = new LambdaQueryWrapper<>();
        if (status != null && !status.isEmpty()) {
            wrapper.eq(Reservation::getStatus, status);
        }
        wrapper.orderByDesc(Reservation::getCreatedTime);

        IPage<Reservation> reservationPage = reservationMapper.selectPage(page, wrapper);
        
        // 转换为VO
        List<ReservationVO> voList = new ArrayList<>();
        for (Reservation reservation : reservationPage.getRecords()) {
            voList.add(buildReservationVO(reservation));
        }

        Page<ReservationVO> voPage = new Page<>(page.getCurrent(), page.getSize(), reservationPage.getTotal());
        voPage.setRecords(voList);
        
        return voPage;
    }

    private ReservationVO buildReservationVO(Reservation reservation) {
        ReservationVO vo = new ReservationVO();
        BeanUtils.copyProperties(reservation, vo);

        // 设置用户信息
        User user = userMapper.selectById(reservation.getUserId());
        if (user != null) {
            vo.setUserName(user.getUsername());
            vo.setUserRealName(user.getRealName());
        }

        // 设置座位信息
        Seat seat = seatMapper.selectById(reservation.getSeatId());
        if (seat != null) {
            vo.setSeatNumber(seat.getSeatNumber());
            vo.setSeatArea(seat.getArea());
            vo.setFloorNumber(seat.getFloorNumber());
        }

        // 计算预约时长
        if (reservation.getStartTime() != null && reservation.getEndTime() != null) {
            Duration duration = Duration.between(reservation.getStartTime(), reservation.getEndTime());
            vo.setDuration(duration.toMinutes() / 60.0);
        }

        // 设置操作权限
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime reservationStart = LocalDateTime.of(reservation.getReservationDate(), reservation.getStartTime());
        LocalDateTime reservationEnd = LocalDateTime.of(reservation.getReservationDate(), reservation.getEndTime());
        
        // 是否可以取消（未支付或已支付且未到开始前30分钟）
        boolean canCancel = ("UNPAID".equals(reservation.getStatus()) ||
                            "RESERVED".equals(reservation.getStatus())) &&
                            now.isBefore(reservationStart.minusMinutes(30));
        vo.setCanCancel(canCancel);

        // 是否可以签到（仅已支付预定可签到）
        boolean canCheckIn = "RESERVED".equals(reservation.getStatus()) && 
                            now.isAfter(reservationStart.minusMinutes(15)) && 
                            now.isBefore(reservationStart.plusMinutes(30));
        vo.setCanCheckIn(canCheckIn);

        // 是否可以签退
        boolean canCheckOut = "USING".equals(reservation.getStatus()) && 
                             now.isBefore(reservationEnd.plusMinutes(30));
        vo.setCanCheckOut(canCheckOut);

        return vo;
    }

    @Override
    public IPage<ReservationVO> getAllReservations(Page<Reservation> page, String status, String startDate, String endDate) {
        LambdaQueryWrapper<Reservation> wrapper = new LambdaQueryWrapper<>();
        
        if (status != null && !status.isEmpty()) {
            wrapper.eq(Reservation::getStatus, status);
        }
        
        if (startDate != null && !startDate.isEmpty()) {
            wrapper.ge(Reservation::getReservationDate, startDate);
        }
        
        if (endDate != null && !endDate.isEmpty()) {
            wrapper.le(Reservation::getReservationDate, endDate);
        }
        
        wrapper.orderByDesc(Reservation::getCreatedTime);

        IPage<Reservation> reservationPage = reservationMapper.selectPage(page, wrapper);
        
        // 转换为VO
        List<ReservationVO> voList = new ArrayList<>();
        for (Reservation reservation : reservationPage.getRecords()) {
            voList.add(buildReservationVO(reservation));
        }

        Page<ReservationVO> voPage = new Page<>(page.getCurrent(), page.getSize(), reservationPage.getTotal());
        voPage.setRecords(voList);
        
        return voPage;
    }

    @Override
    public ReservationVO getReservationDetailByAdmin(Long reservationId) {
        Reservation reservation = reservationMapper.selectById(reservationId);
        if (reservation == null) {
            throw new RuntimeException("预约不存在");
        }

        return buildReservationVO(reservation);
    }

    @Override
    @Transactional
    public void cancelReservationByAdmin(Long reservationId) {
        Reservation reservation = reservationMapper.selectById(reservationId);
        if (reservation == null) {
            throw new RuntimeException("预约不存在");
        }

        if (!"RESERVED".equals(reservation.getStatus()) && !"USING".equals(reservation.getStatus())) {
            throw new RuntimeException("预约状态无法取消");
        }

        LocalDateTime now = LocalDateTime.now();
        reservation.setStatus("CANCELLED");
        reservation.setUpdatedTime(now);
        reservationMapper.updateById(reservation);

        log.info("管理员取消了预约: reservationId={}", reservationId);
    }

    @Override
    @Transactional
    public ReservationVO createReservationByAdmin(ReservationRequest request) {
        // 验证座位存在
        Seat seat = seatMapper.selectById(request.getSeatId());
        if (seat == null) {
            throw new RuntimeException("座位不存在");
        }

        // 验证座位状态
        if (!"AVAILABLE".equals(seat.getStatus())) {
            throw new RuntimeException("座位状态不可用");
        }

        // 验证用户存在（如果指定了用户ID）
        if (request.getUserId() != null) {
            User user = userMapper.selectById(request.getUserId());
            if (user == null) {
                throw new RuntimeException("用户不存在");
            }
        }

        // 检查座位在指定时间段内是否有冲突
        LambdaQueryWrapper<Reservation> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Reservation::getSeatId, request.getSeatId())
                .eq(Reservation::getReservationDate, request.getReservationDate())
                .and(wrapper -> wrapper
                    .and(w -> w.le(Reservation::getStartTime, request.getStartTime())
                             .ge(Reservation::getEndTime, request.getStartTime()))
                    .or(w -> w.le(Reservation::getStartTime, request.getEndTime())
                            .ge(Reservation::getEndTime, request.getEndTime()))
                    .or(w -> w.ge(Reservation::getStartTime, request.getStartTime())
                            .le(Reservation::getEndTime, request.getEndTime()))
                )
                .in(Reservation::getStatus, "RESERVED", "USING");

        long conflictCount = reservationMapper.selectCount(queryWrapper);
        if (conflictCount > 0) {
            throw new RuntimeException("该时间段座位已被预约");
        }

        // 创建预约记录
        Reservation reservation = new Reservation();
        BeanUtils.copyProperties(request, reservation);
        reservation.setStatus("RESERVED");
        LocalDateTime now = LocalDateTime.now();
        reservation.setCreatedTime(now);
        reservation.setUpdatedTime(now);

        reservationMapper.insert(reservation);
        log.info("管理员创建预约成功: reservationId={}", reservation.getId());

        return buildReservationVO(reservation);
    }

    @Override
    @Transactional
    public ReservationVO updateReservationByAdmin(Long reservationId, ReservationRequest request) {
        // 验证预约存在
        Reservation existingReservation = reservationMapper.selectById(reservationId);
        if (existingReservation == null) {
            throw new RuntimeException("预约不存在");
        }

        // 只允许更新未完成的预约
        if ("COMPLETED".equals(existingReservation.getStatus()) || 
            "CANCELLED".equals(existingReservation.getStatus())) {
            throw new RuntimeException("已完成或已取消的预约无法修改");
        }

        // 如果修改了座位，验证新座位
        if (!existingReservation.getSeatId().equals(request.getSeatId())) {
            Seat seat = seatMapper.selectById(request.getSeatId());
            if (seat == null) {
                throw new RuntimeException("座位不存在");
            }
            if (!"AVAILABLE".equals(seat.getStatus())) {
                throw new RuntimeException("座位状态不可用");
            }
        }

        // 检查时间冲突（排除当前预约）
        LambdaQueryWrapper<Reservation> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Reservation::getSeatId, request.getSeatId())
                .eq(Reservation::getReservationDate, request.getReservationDate())
                .ne(Reservation::getId, reservationId)  // 排除当前预约
                .and(wrapper -> wrapper
                    .and(w -> w.le(Reservation::getStartTime, request.getStartTime())
                             .ge(Reservation::getEndTime, request.getStartTime()))
                    .or(w -> w.le(Reservation::getStartTime, request.getEndTime())
                            .ge(Reservation::getEndTime, request.getEndTime()))
                    .or(w -> w.ge(Reservation::getStartTime, request.getStartTime())
                            .le(Reservation::getEndTime, request.getEndTime()))
                )
                .in(Reservation::getStatus, "RESERVED", "USING");

        long conflictCount = reservationMapper.selectCount(queryWrapper);
        if (conflictCount > 0) {
            throw new RuntimeException("该时间段座位已被预约");
        }

        // 更新预约信息
        BeanUtils.copyProperties(request, existingReservation);
        existingReservation.setId(reservationId);
        existingReservation.setUpdatedTime(LocalDateTime.now());

        reservationMapper.updateById(existingReservation);
        log.info("管理员更新预约成功: reservationId={}", reservationId);

        return buildReservationVO(existingReservation);
    }
}
