package com.seatreservation.controller;

import com.seatreservation.service.StatisticsService;
import com.seatreservation.utils.Result;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/statistics")
public class StatisticsController {

    @Autowired
    private StatisticsService statisticsService;

    /**
     * 获取管理员看板统计数据
     */
    @GetMapping("/admin/dashboard")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Map<String, Object>> getDashboardStatistics() {
        try {
            Map<String, Object> result = statisticsService.getDashboardStatistics();
            return Result.success("查询成功", result);
        } catch (Exception e) {
            log.error("获取统计数据失败: {}", e.getMessage());
            return Result.error("查询失败: " + e.getMessage());
        }
    }

    /**
     * 获取预约趋势数据
     */
    @GetMapping("/admin/reservation-trend")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Map<String, Object>> getReservationTrend(
            @RequestParam(defaultValue = "7") Integer days) {
        try {
            Map<String, Object> result = statisticsService.getReservationTrend(days);
            return Result.success("查询成功", result);
        } catch (Exception e) {
            log.error("获取预约趋势数据失败: {}", e.getMessage());
            return Result.error("查询失败: " + e.getMessage());
        }
    }

    /**
     * 获取座位使用率统计
     */
    @GetMapping("/admin/seat-usage")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Map<String, Object>> getSeatUsageStatistics() {
        try {
            Map<String, Object> result = statisticsService.getSeatUsageStatistics();
            return Result.success("查询成功", result);
        } catch (Exception e) {
            log.error("获取座位使用率统计失败: {}", e.getMessage());
            return Result.error("查询失败: " + e.getMessage());
        }
    }

    /**
     * 获取用户活跃度统计
     */
    @GetMapping("/admin/user-activity")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Map<String, Object>> getUserActivityStatistics() {
        try {
            Map<String, Object> result = statisticsService.getUserActivityStatistics();
            return Result.success("查询成功", result);
        } catch (Exception e) {
            log.error("获取用户活跃度统计失败: {}", e.getMessage());
            return Result.error("查询失败: " + e.getMessage());
        }
    }
}