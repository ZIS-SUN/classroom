package com.seatreservation.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.seatreservation.dto.ReservationRequest;
import com.seatreservation.entity.Reservation;
import com.seatreservation.service.ReservationService;
import com.seatreservation.utils.JwtUtils;
import com.seatreservation.utils.Result;
import com.seatreservation.vo.ReservationVO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import javax.validation.Valid;

@Slf4j
@RestController
@RequestMapping("/reservation")
public class ReservationController {

    @Autowired
    private ReservationService reservationService;

    @Autowired
    private JwtUtils jwtUtils;

    /**
     * 创建预约
     */
    @PostMapping("/create")
    public Result<ReservationVO> createReservation(
            @Valid @RequestBody ReservationRequest request,
            HttpServletRequest httpRequest) {
        try {
            Long userId = getCurrentUserId(httpRequest);
            ReservationVO result = reservationService.createReservation(userId, request);
            return Result.success("预约创建成功", result);
        } catch (Exception e) {
            log.error("创建预约失败: {}", e.getMessage());
            return Result.error("创建预约失败: " + e.getMessage());
        }
    }

    /**
     * 取消预约
     */
    @PostMapping("/cancel/{reservationId}")
    public Result<Void> cancelReservation(
            @PathVariable Long reservationId,
            HttpServletRequest httpRequest) {
        try {
            Long userId = getCurrentUserId(httpRequest);
            reservationService.cancelReservation(userId, reservationId);
            return Result.success("预约取消成功", null);
        } catch (Exception e) {
            log.error("取消预约失败: {}", e.getMessage());
            return Result.error("取消预约失败: " + e.getMessage());
        }
    }

    /**
     * 签到
     */
    @PostMapping("/check-in/{reservationId}")
    public Result<Void> checkIn(
            @PathVariable Long reservationId,
            HttpServletRequest httpRequest) {
        try {
            Long userId = getCurrentUserId(httpRequest);
            reservationService.checkIn(userId, reservationId);
            return Result.success("签到成功", null);
        } catch (Exception e) {
            log.error("签到失败: {}", e.getMessage());
            return Result.error("签到失败: " + e.getMessage());
        }
    }

    /**
     * 签退
     */
    @PostMapping("/check-out/{reservationId}")
    public Result<Void> checkOut(
            @PathVariable Long reservationId,
            HttpServletRequest httpRequest) {
        try {
            Long userId = getCurrentUserId(httpRequest);
            reservationService.checkOut(userId, reservationId);
            return Result.success("签退成功", null);
        } catch (Exception e) {
            log.error("签退失败: {}", e.getMessage());
            return Result.error("签退失败: " + e.getMessage());
        }
    }

    /**
     * 获取用户预约列表
     */
    @GetMapping("/my")
    public Result<IPage<ReservationVO>> getUserReservations(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            HttpServletRequest httpRequest) {
        try {
            Long userId = getCurrentUserId(httpRequest);
            Page<Reservation> page = new Page<>(current, size);
            IPage<ReservationVO> result = reservationService.getUserReservations(userId, page);
            return Result.success("查询成功", result);
        } catch (Exception e) {
            log.error("获取用户预约列表失败: {}", e.getMessage());
            return Result.error("查询失败: " + e.getMessage());
        }
    }

    /**
     * 获取预约详情
     */
    @GetMapping("/{reservationId}")
    public Result<ReservationVO> getReservationDetail(
            @PathVariable Long reservationId,
            HttpServletRequest httpRequest) {
        try {
            Long userId = getCurrentUserId(httpRequest);
            ReservationVO result = reservationService.getReservationDetail(userId, reservationId);
            return Result.success("查询成功", result);
        } catch (Exception e) {
            log.error("获取预约详情失败: {}", e.getMessage());
            return Result.error("查询失败: " + e.getMessage());
        }
    }

    /**
     * 管理员获取所有预约列表
     */
    @GetMapping("/admin/list")
    public Result<IPage<ReservationVO>> getAllReservations(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate) {
        try {
            Page<Reservation> page = new Page<>(current, size);
            IPage<ReservationVO> result = reservationService.getAllReservations(page, status, startDate, endDate);
            return Result.success("查询成功", result);
        } catch (Exception e) {
            log.error("管理员获取预约列表失败: {}", e.getMessage());
            return Result.error("查询失败: " + e.getMessage());
        }
    }

    /**
     * 管理员获取预约详情
     */
    @GetMapping("/admin/{reservationId}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<ReservationVO> getReservationDetailByAdmin(@PathVariable Long reservationId) {
        try {
            ReservationVO result = reservationService.getReservationDetailByAdmin(reservationId);
            if (result == null) {
                return Result.error("预约不存在");
            }
            return Result.success("查询成功", result);
        } catch (Exception e) {
            log.error("管理员获取预约详情失败: {}", e.getMessage());
            return Result.error("查询失败: " + e.getMessage());
        }
    }

    /**
     * 管理员创建预约
     */
    @PostMapping("/admin/create")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<ReservationVO> createReservationByAdmin(@Valid @RequestBody ReservationRequest request) {
        try {
            ReservationVO result = reservationService.createReservationByAdmin(request);
            return Result.success("预约创建成功", result);
        } catch (Exception e) {
            log.error("管理员创建预约失败: {}", e.getMessage());
            return Result.error("创建预约失败: " + e.getMessage());
        }
    }

    /**
     * 管理员更新预约
     */
    @PutMapping("/admin/{reservationId}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<ReservationVO> updateReservationByAdmin(@PathVariable Long reservationId, @Valid @RequestBody ReservationRequest request) {
        try {
            ReservationVO result = reservationService.updateReservationByAdmin(reservationId, request);
            return Result.success("预约更新成功", result);
        } catch (Exception e) {
            log.error("管理员更新预约失败: {}", e.getMessage());
            return Result.error("更新预约失败: " + e.getMessage());
        }
    }

    /**
     * 管理员取消预约
     */
    @PostMapping("/admin/cancel/{reservationId}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Void> cancelReservationByAdmin(@PathVariable Long reservationId) {
        try {
            reservationService.cancelReservationByAdmin(reservationId);
            return Result.success("预约取消成功", null);
        } catch (Exception e) {
            log.error("管理员取消预约失败: {}", e.getMessage());
            return Result.error("取消预约失败: " + e.getMessage());
        }
    }

    /**
     * 从HTTP请求中获取当前用户ID
     */
    private Long getCurrentUserId(HttpServletRequest request) {
        String token = getTokenFromRequest(request);
        if (token == null) {
            throw new RuntimeException("未找到认证token");
        }
        
        if (!jwtUtils.validateToken(token)) {
            throw new RuntimeException("无效的token");
        }
        
        return jwtUtils.getUserIdFromToken(token);
    }

    /**
     * 从HTTP请求中提取token
     */
    private String getTokenFromRequest(HttpServletRequest request) {
        String authHeader = request.getHeader("Authorization");
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            return authHeader.substring(7);
        }
        return null;
    }
}