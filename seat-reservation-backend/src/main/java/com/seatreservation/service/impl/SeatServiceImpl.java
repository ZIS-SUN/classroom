package com.seatreservation.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.seatreservation.dto.SeatQueryRequest;
import com.seatreservation.entity.Reservation;
import com.seatreservation.entity.Seat;
import com.seatreservation.entity.SeatType;
import com.seatreservation.mapper.ReservationMapper;
import com.seatreservation.mapper.SeatMapper;
import com.seatreservation.mapper.SeatTypeMapper;
import com.seatreservation.service.SeatService;
import com.seatreservation.vo.SeatVO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Slf4j
@Service
public class SeatServiceImpl extends ServiceImpl<SeatMapper, Seat> implements SeatService {

    @Autowired
    private SeatTypeMapper seatTypeMapper;
    
    @Autowired
    private ReservationMapper reservationMapper;

    @Override
    public IPage<SeatVO> getSeatPage(Page<Seat> page, SeatQueryRequest request) {
        QueryWrapper<Seat> queryWrapper = buildQueryWrapper(request);
        
        IPage<Seat> seatPage = page(page, queryWrapper);
        
        // 获取所有座位类型
        List<SeatType> seatTypes = seatTypeMapper.selectList(null);
        Map<Integer, SeatType> seatTypeMap = seatTypes.stream()
                .collect(Collectors.toMap(SeatType::getId, type -> type));
        
        // 转换为VO
        IPage<SeatVO> result = seatPage.convert(seat -> {
            SeatVO vo = new SeatVO();
            BeanUtils.copyProperties(seat, vo);
            
            SeatType seatType = seatTypeMap.get(seat.getSeatTypeId());
            if (seatType != null) {
                vo.setSeatTypeName(seatType.getTypeName());
                vo.setHourlyRate(seatType.getHourlyRate());
            }
            
            // 检查时间段内是否可用
            if (request.getDate() != null && request.getStartTime() != null && request.getEndTime() != null) {
                vo.setAvailable(checkSeatAvailable(seat.getId(), request.getDate(), 
                    request.getStartTime(), request.getEndTime()));
            } else {
                vo.setAvailable("AVAILABLE".equals(seat.getStatus()));
            }
            
            return vo;
        });
        
        return result;
    }

    @Override
    public List<SeatType> getAllSeatTypes() {
        return seatTypeMapper.selectList(null);
    }

    @Override
    public List<SeatVO> getAvailableSeats(String area, Integer floorNumber, Integer seatTypeId, 
                                         LocalDate date, LocalTime startTime, LocalTime endTime) {
        QueryWrapper<Seat> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("status", "AVAILABLE");
        
        if (StringUtils.hasText(area)) {
            queryWrapper.eq("area", area);
        }
        if (floorNumber != null) {
            queryWrapper.eq("floor_number", floorNumber);
        }
        if (seatTypeId != null) {
            queryWrapper.eq("seat_type_id", seatTypeId);
        }
        
        List<Seat> seats = list(queryWrapper);
        
        // 获取座位类型信息
        List<SeatType> seatTypes = seatTypeMapper.selectList(null);
        Map<Integer, SeatType> seatTypeMap = seatTypes.stream()
                .collect(Collectors.toMap(SeatType::getId, type -> type));
        
        List<SeatVO> result = new ArrayList<>();
        for (Seat seat : seats) {
            if (checkSeatAvailable(seat.getId(), date, startTime, endTime)) {
                SeatVO vo = new SeatVO();
                BeanUtils.copyProperties(seat, vo);
                
                SeatType seatType = seatTypeMap.get(seat.getSeatTypeId());
                if (seatType != null) {
                    vo.setSeatTypeName(seatType.getTypeName());
                    vo.setHourlyRate(seatType.getHourlyRate());
                }
                vo.setAvailable(true);
                result.add(vo);
            }
        }
        
        return result;
    }

    @Override
    public SeatVO getSeatDetail(Long seatId) {
        Seat seat = getById(seatId);
        if (seat == null) {
            return null;
        }
        
        SeatVO vo = new SeatVO();
        BeanUtils.copyProperties(seat, vo);
        
        // 获取座位类型信息
        SeatType seatType = seatTypeMapper.selectById(seat.getSeatTypeId());
        if (seatType != null) {
            vo.setSeatTypeName(seatType.getTypeName());
            vo.setHourlyRate(seatType.getHourlyRate());
        }
        
        vo.setAvailable("AVAILABLE".equals(seat.getStatus()));
        
        return vo;
    }

    @Override
    public void updateSeatStatus(Long seatId, String status) {
        Seat seat = new Seat();
        seat.setId(seatId);
        seat.setStatus(status);
        updateById(seat);
        
        log.info("更新座位状态: seatId={}, status={}", seatId, status);
    }
    
    private QueryWrapper<Seat> buildQueryWrapper(SeatQueryRequest request) {
        QueryWrapper<Seat> queryWrapper = new QueryWrapper<>();
        
        if (StringUtils.hasText(request.getSeatNumber())) {
            queryWrapper.like("seat_number", request.getSeatNumber());
        }
        if (request.getFloorNumber() != null) {
            queryWrapper.eq("floor_number", request.getFloorNumber());
        }
        if (StringUtils.hasText(request.getArea())) {
            queryWrapper.eq("area", request.getArea());
        }
        if (request.getSeatTypeId() != null) {
            queryWrapper.eq("seat_type_id", request.getSeatTypeId());
        }
        if (StringUtils.hasText(request.getStatus())) {
            queryWrapper.eq("status", request.getStatus());
        }
        if (request.getHasPower() != null) {
            queryWrapper.eq("has_power", request.getHasPower());
        }
        if (request.getHasComputer() != null) {
            queryWrapper.eq("has_computer", request.getHasComputer());
        }
        
        queryWrapper.orderByAsc("floor_number", "area", "seat_number");
        
        return queryWrapper;
    }

    @Override
    public boolean hasActiveReservations(Long seatId) {
        QueryWrapper<Reservation> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("seat_id", seatId)
                   .in("status", "RESERVED", "USING", "COMPLETED");

        return reservationMapper.selectCount(queryWrapper) > 0;
    }

    private boolean checkSeatAvailable(Long seatId, LocalDate date, LocalTime startTime, LocalTime endTime) {
        if (date == null || startTime == null || endTime == null) {
            return true;
        }
        
        QueryWrapper<Reservation> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("seat_id", seatId)
                   .eq("reservation_date", date)
                   .in("status", "RESERVED", "USING")
                   .and(wrapper -> wrapper
                       .or(w -> w.le("start_time", startTime).gt("end_time", startTime))
                       .or(w -> w.lt("start_time", endTime).ge("end_time", endTime))
                       .or(w -> w.ge("start_time", startTime).le("end_time", endTime))
                   );
        
        return reservationMapper.selectCount(queryWrapper) == 0;
    }
}