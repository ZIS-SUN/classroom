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
}