package com.seatreservation.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.seatreservation.entity.Reservation;
import com.seatreservation.entity.Seat;
import com.seatreservation.entity.User;
import com.seatreservation.mapper.ReservationMapper;
import com.seatreservation.mapper.SeatMapper;
import com.seatreservation.mapper.UserMapper;
import com.seatreservation.service.StatisticsService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Slf4j
@Service
public class StatisticsServiceImpl implements StatisticsService {

    @Autowired
    private ReservationMapper reservationMapper;

    @Autowired
    private SeatMapper seatMapper;

    @Autowired
    private UserMapper userMapper;

    @Override
    public Map<String, Object> getDashboardStatistics() {
        Map<String, Object> result = new HashMap<>();
        
        try {
            // 今日预约数
            LocalDate today = LocalDate.now();
            QueryWrapper<Reservation> todayQuery = new QueryWrapper<>();
            todayQuery.eq("reservation_date", today);
            Integer todayReservations = Math.toIntExact(reservationMapper.selectCount(todayQuery));
            
            // 总座位数
            Integer totalSeats = Math.toIntExact(seatMapper.selectCount(null));
            
            // 可用座位数
            QueryWrapper<Seat> availableSeatQuery = new QueryWrapper<>();
            availableSeatQuery.eq("status", "AVAILABLE");
            Integer availableSeats = Math.toIntExact(seatMapper.selectCount(availableSeatQuery));
            
            // 活跃用户数（本周有预约的用户）
            LocalDate weekStart = today.minusDays(7);
            QueryWrapper<Reservation> weekQuery = new QueryWrapper<>();
            weekQuery.ge("reservation_date", weekStart);
            weekQuery.select("DISTINCT user_id");
            List<Reservation> weekReservations = reservationMapper.selectList(weekQuery);
            Set<Long> activeUserIds = new HashSet<>();
            for (Reservation r : weekReservations) {
                activeUserIds.add(r.getUserId());
            }
            Integer activeUsers = activeUserIds.size();
            
            // 今日收入（模拟数据）
            Double todayRevenue = todayReservations * 15.5; // 假设平均每单15.5元
            
            result.put("todayReservations", todayReservations);
            result.put("totalSeats", totalSeats);
            result.put("availableSeats", availableSeats);
            result.put("activeUsers", activeUsers);
            result.put("todayRevenue", todayRevenue);
            
        } catch (Exception e) {
            log.error("获取看板统计数据失败", e);
            // 返回默认值
            result.put("todayReservations", 0);
            result.put("totalSeats", 0);
            result.put("availableSeats", 0);
            result.put("activeUsers", 0);
            result.put("todayRevenue", 0.0);
        }
        
        return result;
    }

    @Override
    public Map<String, Object> getReservationTrend(Integer days) {
        Map<String, Object> result = new HashMap<>();
        List<Map<String, Object>> trendData = new ArrayList<>();
        
        try {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("MM-dd");
            LocalDate endDate = LocalDate.now();
            LocalDate startDate = endDate.minusDays(days - 1);
            
            for (LocalDate date = startDate; !date.isAfter(endDate); date = date.plusDays(1)) {
                QueryWrapper<Reservation> query = new QueryWrapper<>();
                query.eq("reservation_date", date);
                Long count = reservationMapper.selectCount(query);
                
                Map<String, Object> dayData = new HashMap<>();
                dayData.put("date", date.format(formatter));
                dayData.put("count", count);
                trendData.add(dayData);
            }
            
            result.put("trend", trendData);
            
        } catch (Exception e) {
            log.error("获取预约趋势数据失败", e);
            result.put("trend", new ArrayList<>());
        }
        
        return result;
    }

    @Override
    public Map<String, Object> getSeatUsageStatistics() {
        Map<String, Object> result = new HashMap<>();
        
        try {
            // 座位类型使用统计
            List<Map<String, Object>> seatTypeUsage = new ArrayList<>();
            
            // 获取所有座位及其类型
            List<Seat> allSeats = seatMapper.selectList(null);
            Map<String, Integer> typeCount = new HashMap<>();
            Map<String, Integer> typeUsed = new HashMap<>();
            
            for (Seat seat : allSeats) {
                String typeName = getSeatTypeName(seat.getSeatTypeId());
                typeCount.put(typeName, typeCount.getOrDefault(typeName, 0) + 1);
                
                // 检查座位是否被占用
                if ("OCCUPIED".equals(seat.getStatus())) {
                    typeUsed.put(typeName, typeUsed.getOrDefault(typeName, 0) + 1);
                }
            }
            
            for (String typeName : typeCount.keySet()) {
                Map<String, Object> usage = new HashMap<>();
                usage.put("typeName", typeName);
                usage.put("total", typeCount.get(typeName));
                usage.put("used", typeUsed.getOrDefault(typeName, 0));
                double rate = typeCount.get(typeName) > 0 ? 
                    (double) typeUsed.getOrDefault(typeName, 0) / typeCount.get(typeName) * 100 : 0;
                usage.put("usageRate", Math.round(rate * 100.0) / 100.0);
                seatTypeUsage.add(usage);
            }
            
            result.put("seatTypeUsage", seatTypeUsage);
            
        } catch (Exception e) {
            log.error("获取座位使用率统计失败", e);
            result.put("seatTypeUsage", new ArrayList<>());
        }
        
        return result;
    }

    @Override
    public Map<String, Object> getUserActivityStatistics() {
        Map<String, Object> result = new HashMap<>();
        
        try {
            // 总用户数
            Integer totalUsers = Math.toIntExact(userMapper.selectCount(null));
            
            // 活跃用户数（本周有预约）
            LocalDate weekStart = LocalDate.now().minusDays(7);
            QueryWrapper<Reservation> weekQuery = new QueryWrapper<>();
            weekQuery.ge("reservation_date", weekStart);
            weekQuery.select("DISTINCT user_id");
            List<Reservation> weekReservations = reservationMapper.selectList(weekQuery);
            Integer activeUsers = weekReservations.size();
            
            // 新注册用户数（本周）
            LocalDateTime weekStartTime = weekStart.atStartOfDay();
            QueryWrapper<User> newUserQuery = new QueryWrapper<>();
            newUserQuery.ge("created_time", weekStartTime);
            Integer newUsers = Math.toIntExact(userMapper.selectCount(newUserQuery));
            
            result.put("totalUsers", totalUsers);
            result.put("activeUsers", activeUsers);
            result.put("newUsers", newUsers);
            
        } catch (Exception e) {
            log.error("获取用户活跃度统计失败", e);
            result.put("totalUsers", 0);
            result.put("activeUsers", 0);
            result.put("newUsers", 0);
        }
        
        return result;
    }

    private String getSeatTypeName(Integer seatTypeId) {
        // 根据座位类型ID返回类型名称
        switch (seatTypeId) {
            case 1: return "普通座位";
            case 2: return "靠窗座位";
            case 3: return "独立包间";
            case 4: return "电脑座位";
            default: return "未知类型";
        }
    }
}