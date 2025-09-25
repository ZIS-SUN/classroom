package com.seatreservation.service;

import java.util.Map;

public interface StatisticsService {
    
    /**
     * 获取管理员看板统计数据
     */
    Map<String, Object> getDashboardStatistics();
    
    /**
     * 获取预约趋势数据
     */
    Map<String, Object> getReservationTrend(Integer days);
    
    /**
     * 获取座位使用率统计
     */
    Map<String, Object> getSeatUsageStatistics();
    
    /**
     * 获取用户活跃度统计
     */
    Map<String, Object> getUserActivityStatistics();
    
    /**
     * 获取收入统计
     */
    Map<String, Object> getRevenueStatistics(Integer days);
    
    /**
     * 获取热门时段统计
     */
    Map<String, Object> getPeakHoursStatistics();
    
    /**
     * 获取座位使用热力图数据
     */
    Map<String, Object> getHeatmapData(Integer days);
    
    /**
     * 获取综合报表数据
     */
    Map<String, Object> getComprehensiveReport(Integer days);

    /**
     * 获取座位类型分布
     */
    Map<String, Object> getSeatTypeDistribution();

    /**
     * 获取最近预约记录
     */
    Map<String, Object> getRecentReservations(Integer limit);

    /**
     * 获取座位使用排行
     */
    Map<String, Object> getTopSeats(Integer limit);

    /**
     * 获取时段预约分析
     */
    Map<String, Object> getHourlyReservations(String date);
}