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

    /**
     * 获取收入统计
     */
    @GetMapping("/admin/revenue")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Map<String, Object>> getRevenueStatistics(
            @RequestParam(defaultValue = "30") Integer days) {
        try {
            Map<String, Object> result = statisticsService.getRevenueStatistics(days);
            return Result.success("查询成功", result);
        } catch (Exception e) {
            log.error("获取收入统计失败: {}", e.getMessage());
            return Result.error("查询失败: " + e.getMessage());
        }
    }

    /**
     * 获取热门时段统计
     */
    @GetMapping("/admin/peak-hours")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Map<String, Object>> getPeakHoursStatistics() {
        try {
            Map<String, Object> result = statisticsService.getPeakHoursStatistics();
            return Result.success("查询成功", result);
        } catch (Exception e) {
            log.error("获取热门时段统计失败: {}", e.getMessage());
            return Result.error("查询失败: " + e.getMessage());
        }
    }

    /**
     * 获取座位使用热力图数据
     */
    @GetMapping("/admin/heatmap")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Map<String, Object>> getHeatmapData(
            @RequestParam(defaultValue = "7") Integer days) {
        try {
            Map<String, Object> result = statisticsService.getHeatmapData(days);
            return Result.success("查询成功", result);
        } catch (Exception e) {
            log.error("获取热力图数据失败: {}", e.getMessage());
            return Result.error("查询失败: " + e.getMessage());
        }
    }

    /**
     * 获取综合报表数据
     */
    @GetMapping("/admin/comprehensive-report")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Map<String, Object>> getComprehensiveReport(
            @RequestParam(defaultValue = "30") Integer days) {
        try {
            Map<String, Object> result = statisticsService.getComprehensiveReport(days);
            return Result.success("查询成功", result);
        } catch (Exception e) {
            log.error("获取综合报表失败: {}", e.getMessage());
            return Result.error("查询失败: " + e.getMessage());
        }
    }

    /**
     * 获取座位类型分布
     */
    @GetMapping("/admin/seat-types")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Map<String, Object>> getSeatTypeDistribution() {
        try {
            Map<String, Object> result = statisticsService.getSeatTypeDistribution();
            return Result.success("查询成功", result);
        } catch (Exception e) {
            log.error("获取座位类型分布失败: {}", e.getMessage());
            return Result.error("查询失败: " + e.getMessage());
        }
    }

    /**
     * 获取最近预约记录
     */
    @GetMapping("/admin/recent-reservations")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Map<String, Object>> getRecentReservations(
            @RequestParam(defaultValue = "10") Integer limit) {
        try {
            Map<String, Object> result = statisticsService.getRecentReservations(limit);
            return Result.success("查询成功", result);
        } catch (Exception e) {
            log.error("获取最近预约记录失败: {}", e.getMessage());
            return Result.error("查询失败: " + e.getMessage());
        }
    }

    /**
     * 获取座位使用排行
     */
    @GetMapping("/admin/top-seats")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Map<String, Object>> getTopSeats(
            @RequestParam(defaultValue = "10") Integer limit) {
        try {
            Map<String, Object> result = statisticsService.getTopSeats(limit);
            return Result.success("查询成功", result);
        } catch (Exception e) {
            log.error("获取座位使用排行失败: {}", e.getMessage());
            return Result.error("查询失败: " + e.getMessage());
        }
    }

    /**
     * 获取时段预约分析
     */
    @GetMapping("/admin/hourly-reservations")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Map<String, Object>> getHourlyReservations(
            @RequestParam String date) {
        try {
            Map<String, Object> result = statisticsService.getHourlyReservations(date);
            return Result.success("查询成功", result);
        } catch (Exception e) {
            log.error("获取时段预约分析失败: {}", e.getMessage());
            return Result.error("查询失败: " + e.getMessage());
        }
    }
}