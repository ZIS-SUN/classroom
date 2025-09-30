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
            
            // 今日收入（从实际预约费用计算）
            QueryWrapper<Reservation> revenueQuery = new QueryWrapper<>();
            revenueQuery.eq("reservation_date", today);
            revenueQuery.in("status", "COMPLETED", "USING");
            List<Reservation> todayCompletedReservations = reservationMapper.selectList(revenueQuery);
            Double todayRevenue = 0.0;
            for (Reservation r : todayCompletedReservations) {
                if (r.getTotalFee() != null) {
                    todayRevenue += r.getTotalFee().doubleValue();
                }
            }
            
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

    @Override
    public Map<String, Object> getRevenueStatistics(Integer days) {
        Map<String, Object> result = new HashMap<>();
        List<Map<String, Object>> revenueData = new ArrayList<>();
        
        try {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("MM-dd");
            LocalDate endDate = LocalDate.now();
            LocalDate startDate = endDate.minusDays(days - 1);
            
            double totalRevenue = 0.0;
            
            for (LocalDate date = startDate; !date.isAfter(endDate); date = date.plusDays(1)) {
                QueryWrapper<Reservation> query = new QueryWrapper<>();
                query.eq("reservation_date", date);
                query.eq("status", "COMPLETED");
                Long count = reservationMapper.selectCount(query);
                
                // 计算当日实际收入
                QueryWrapper<Reservation> dailyRevenueQuery = new QueryWrapper<>();
                dailyRevenueQuery.eq("reservation_date", date);
                dailyRevenueQuery.eq("status", "COMPLETED");
                List<Reservation> completedReservations = reservationMapper.selectList(dailyRevenueQuery);
                double dailyRevenue = 0.0;
                for (Reservation r : completedReservations) {
                    if (r.getTotalFee() != null) {
                        dailyRevenue += r.getTotalFee().doubleValue();
                    }
                }
                totalRevenue += dailyRevenue;
                
                Map<String, Object> dayData = new HashMap<>();
                dayData.put("date", date.format(formatter));
                dayData.put("revenue", dailyRevenue);
                revenueData.add(dayData);
            }
            
            result.put("revenueData", revenueData);
            result.put("totalRevenue", totalRevenue);
            result.put("averageRevenue", totalRevenue / days);
            
        } catch (Exception e) {
            log.error("获取收入统计失败", e);
            result.put("revenueData", new ArrayList<>());
            result.put("totalRevenue", 0.0);
            result.put("averageRevenue", 0.0);
        }
        
        return result;
    }

    @Override
    public Map<String, Object> getPeakHoursStatistics() {
        Map<String, Object> result = new HashMap<>();
        List<Map<String, Object>> hourlyData = new ArrayList<>();
        
        try {
            // 统计最近7天每小时的预约数量
            LocalDate weekStart = LocalDate.now().minusDays(7);
            Map<Integer, Integer> hourlyCount = new HashMap<>();
            
            // 初始化24小时数据
            for (int hour = 0; hour < 24; hour++) {
                hourlyCount.put(hour, 0);
            }
            
            // 从数据库查询实际的每小时预约数据
            QueryWrapper<Reservation> weeklyQuery = new QueryWrapper<>();
            weeklyQuery.ge("reservation_date", weekStart);
            List<Reservation> weekReservations = reservationMapper.selectList(weeklyQuery);

            for (Reservation reservation : weekReservations) {
                if (reservation.getStartTime() != null) {
                    int hour = reservation.getStartTime().getHour();
                    hourlyCount.put(hour, hourlyCount.get(hour) + 1);
                }
            }
            
            for (int hour = 0; hour < 24; hour++) {
                Map<String, Object> data = new HashMap<>();
                data.put("hour", String.format("%02d:00", hour));
                data.put("count", hourlyCount.get(hour));
                hourlyData.add(data);
            }
            
            result.put("hourlyData", hourlyData);
            
        } catch (Exception e) {
            log.error("获取热门时段统计失败", e);
            result.put("hourlyData", new ArrayList<>());
        }
        
        return result;
    }

    @Override
    public Map<String, Object> getHeatmapData(Integer days) {
        Map<String, Object> result = new HashMap<>();
        List<Map<String, Object>> heatmapData = new ArrayList<>();
        
        try {
            // 生成热力图数据 (日期 x 小时)
            LocalDate endDate = LocalDate.now();
            LocalDate startDate = endDate.minusDays(days - 1);
            
            for (LocalDate date = startDate; !date.isAfter(endDate); date = date.plusDays(1)) {
                for (int hour = 0; hour < 24; hour++) {
                    Map<String, Object> point = new HashMap<>();
                    point.put("date", date.toString());
                    point.put("hour", hour);
                    
                    // 从数据库查询该日期该小时的实际预约数量
                    QueryWrapper<Reservation> heatQuery = new QueryWrapper<>();
                    heatQuery.eq("reservation_date", date);
                    List<Reservation> dayReservations = reservationMapper.selectList(heatQuery);

                    int intensity = 0;
                    for (Reservation r : dayReservations) {
                        if (r.getStartTime() != null && r.getStartTime().getHour() == hour) {
                            intensity++;
                        }
                    }
                    
                    point.put("intensity", intensity);
                    heatmapData.add(point);
                }
            }
            
            result.put("heatmapData", heatmapData);
            
        } catch (Exception e) {
            log.error("获取热力图数据失败", e);
            result.put("heatmapData", new ArrayList<>());
        }
        
        return result;
    }

    @Override
    public Map<String, Object> getComprehensiveReport(Integer days) {
        Map<String, Object> result = new HashMap<>();
        
        try {
            // 获取各种统计数据
            Map<String, Object> dashboard = getDashboardStatistics();
            Map<String, Object> trend = getReservationTrend(days);
            Map<String, Object> seatUsage = getSeatUsageStatistics();
            Map<String, Object> userActivity = getUserActivityStatistics();
            Map<String, Object> revenue = getRevenueStatistics(days);
            Map<String, Object> peakHours = getPeakHoursStatistics();
            
            // 计算综合指标
            Map<String, Object> summary = new HashMap<>();
            summary.put("reportPeriod", days + "天");
            summary.put("totalReservations", dashboard.get("todayReservations"));
            summary.put("totalRevenue", revenue.get("totalRevenue"));
            summary.put("averageDailyRevenue", revenue.get("averageRevenue"));
            summary.put("seatUtilizationRate", calculateSeatUtilizationRate());
            summary.put("userGrowthRate", calculateUserGrowthRate());
            summary.put("popularTimeSlot", "14:00-17:00");
            
            result.put("summary", summary);
            result.put("dashboard", dashboard);
            result.put("trend", trend);
            result.put("seatUsage", seatUsage);
            result.put("userActivity", userActivity);
            result.put("revenue", revenue);
            result.put("peakHours", peakHours);
            
        } catch (Exception e) {
            log.error("获取综合报表失败", e);
            result.put("summary", new HashMap<>());
        }
        
        return result;
    }

    private double calculateSeatUtilizationRate() {
        try {
            Integer totalSeats = Math.toIntExact(seatMapper.selectCount(null));
            QueryWrapper<Seat> occupiedQuery = new QueryWrapper<>();
            occupiedQuery.eq("status", "OCCUPIED");
            Integer occupiedSeats = Math.toIntExact(seatMapper.selectCount(occupiedQuery));
            
            return totalSeats > 0 ? (double) occupiedSeats / totalSeats * 100 : 0;
        } catch (Exception e) {
            return 0.0;
        }
    }

    private double calculateUserGrowthRate() {
        try {
            // 计算本周新增用户与上周对比的增长率
            LocalDate thisWeekStart = LocalDate.now().minusDays(7);
            LocalDate lastWeekStart = thisWeekStart.minusDays(7);
            
            QueryWrapper<User> thisWeekQuery = new QueryWrapper<>();
            thisWeekQuery.ge("created_time", thisWeekStart.atStartOfDay());
            Integer thisWeekUsers = Math.toIntExact(userMapper.selectCount(thisWeekQuery));
            
            QueryWrapper<User> lastWeekQuery = new QueryWrapper<>();
            lastWeekQuery.ge("created_time", lastWeekStart.atStartOfDay());
            lastWeekQuery.lt("created_time", thisWeekStart.atStartOfDay());
            Integer lastWeekUsers = Math.toIntExact(userMapper.selectCount(lastWeekQuery));
            
            if (lastWeekUsers == 0) return thisWeekUsers > 0 ? 100.0 : 0.0;
            return ((double) (thisWeekUsers - lastWeekUsers) / lastWeekUsers) * 100;
        } catch (Exception e) {
            return 0.0;
        }
    }

    @Override
    public Map<String, Object> getSeatTypeDistribution() {
        Map<String, Object> result = new HashMap<>();
        List<Map<String, Object>> distribution = new ArrayList<>();

        try {
            // 统计各类型座位的数量和使用情况
            List<Seat> allSeats = seatMapper.selectList(null);
            Map<Integer, Integer> typeCount = new HashMap<>();
            Map<Integer, Integer> typeUsed = new HashMap<>();

            for (Seat seat : allSeats) {
                Integer typeId = seat.getSeatTypeId();
                typeCount.put(typeId, typeCount.getOrDefault(typeId, 0) + 1);

                if ("OCCUPIED".equals(seat.getStatus())) {
                    typeUsed.put(typeId, typeUsed.getOrDefault(typeId, 0) + 1);
                }
            }

            for (Map.Entry<Integer, Integer> entry : typeCount.entrySet()) {
                Integer typeId = entry.getKey();
                Integer total = entry.getValue();
                Integer used = typeUsed.getOrDefault(typeId, 0);

                Map<String, Object> typeInfo = new HashMap<>();
                typeInfo.put("typeName", getSeatTypeName(typeId));
                typeInfo.put("total", total);
                typeInfo.put("used", used);
                typeInfo.put("available", total - used);
                typeInfo.put("usageRate", total > 0 ? (double) used / total * 100 : 0);

                distribution.add(typeInfo);
            }

            result.put("distribution", distribution);

        } catch (Exception e) {
            log.error("获取座位类型分布失败", e);
            result.put("distribution", new ArrayList<>());
        }

        return result;
    }

    @Override
    public Map<String, Object> getRecentReservations(Integer limit) {
        Map<String, Object> result = new HashMap<>();
        List<Map<String, Object>> recentReservations = new ArrayList<>();

        try {
            // 查询最近的预约记录
            QueryWrapper<Reservation> query = new QueryWrapper<>();
            query.orderByDesc("created_time");
            query.last("LIMIT " + limit);

            List<Reservation> reservations = reservationMapper.selectList(query);

            for (Reservation reservation : reservations) {
                Map<String, Object> info = new HashMap<>();
                info.put("id", reservation.getId());
                info.put("userId", reservation.getUserId());
                info.put("seatId", reservation.getSeatId());
                info.put("reservationDate", reservation.getReservationDate());
                info.put("startTime", reservation.getStartTime());
                info.put("endTime", reservation.getEndTime());
                info.put("status", reservation.getStatus());
                info.put("totalFee", reservation.getTotalFee());
                info.put("createdTime", reservation.getCreatedTime());

                // 获取用户信息
                User user = userMapper.selectById(reservation.getUserId());
                if (user != null) {
                    info.put("username", user.getUsername());
                    info.put("realName", user.getRealName());
                }

                // 获取座位信息
                Seat seat = seatMapper.selectById(reservation.getSeatId());
                if (seat != null) {
                    info.put("seatNumber", seat.getSeatNumber());
                    info.put("area", seat.getArea());
                }

                recentReservations.add(info);
            }

            result.put("reservations", recentReservations);

        } catch (Exception e) {
            log.error("获取最近预约记录失败", e);
            result.put("reservations", new ArrayList<>());
        }

        return result;
    }

    @Override
    public Map<String, Object> getTopSeats(Integer limit) {
        Map<String, Object> result = new HashMap<>();
        List<Map<String, Object>> topSeats = new ArrayList<>();

        try {
            // 统计座位使用次数
            List<Seat> allSeats = seatMapper.selectList(null);
            List<Map<String, Object>> seatUsageList = new ArrayList<>();

            for (Seat seat : allSeats) {
                QueryWrapper<Reservation> usageQuery = new QueryWrapper<>();
                usageQuery.eq("seat_id", seat.getId());
                usageQuery.in("status", "COMPLETED", "USING");
                Long usageCount = reservationMapper.selectCount(usageQuery);

                // 计算总使用时长和收入
                QueryWrapper<Reservation> detailQuery = new QueryWrapper<>();
                detailQuery.eq("seat_id", seat.getId());
                detailQuery.eq("status", "COMPLETED");
                List<Reservation> completedReservations = reservationMapper.selectList(detailQuery);

                double totalHours = 0.0;
                double totalRevenue = 0.0;
                for (Reservation r : completedReservations) {
                    if (r.getStartTime() != null && r.getEndTime() != null) {
                        totalHours += java.time.Duration.between(r.getStartTime(), r.getEndTime()).toHours();
                    }
                    if (r.getTotalFee() != null) {
                        totalRevenue += r.getTotalFee().doubleValue();
                    }
                }

                Map<String, Object> seatInfo = new HashMap<>();
                seatInfo.put("seatId", seat.getId());
                seatInfo.put("seatNumber", seat.getSeatNumber());
                seatInfo.put("area", seat.getArea());
                seatInfo.put("typeName", getSeatTypeName(seat.getSeatTypeId()));
                seatInfo.put("usageCount", usageCount);
                seatInfo.put("totalHours", totalHours);
                seatInfo.put("totalRevenue", totalRevenue);
                seatInfo.put("averageHours", usageCount > 0 ? totalHours / usageCount : 0);

                seatUsageList.add(seatInfo);
            }

            // 按使用次数排序并取前N个
            seatUsageList.sort((a, b) -> Long.compare((Long) b.get("usageCount"), (Long) a.get("usageCount")));

            int actualLimit = Math.min(limit, seatUsageList.size());
            for (int i = 0; i < actualLimit; i++) {
                topSeats.add(seatUsageList.get(i));
            }

            result.put("topSeats", topSeats);

        } catch (Exception e) {
            log.error("获取座位使用排行失败", e);
            result.put("topSeats", new ArrayList<>());
        }

        return result;
    }

    @Override
    public Map<String, Object> getHourlyReservations(String date) {
        Map<String, Object> result = new HashMap<>();
        List<Map<String, Object>> hourlyData = new ArrayList<>();

        try {
            LocalDate targetDate = LocalDate.parse(date);

            // 生成24小时的时段数据
            for (int hour = 0; hour < 24; hour++) {
                LocalDateTime startTime = targetDate.atTime(hour, 0);
                LocalDateTime endTime = targetDate.atTime(hour, 59, 59);

                // 查询该时段的预约数量
                QueryWrapper<Reservation> query = new QueryWrapper<>();
                query.eq("reservation_date", targetDate);
                query.ge("start_time", startTime.toLocalTime());
                query.lt("start_time", endTime.toLocalTime());

                Long count = reservationMapper.selectCount(query);

                Map<String, Object> hourInfo = new HashMap<>();
                hourInfo.put("hour", hour);
                hourInfo.put("time", String.format("%02d:00", hour));
                hourInfo.put("count", count != null ? count.intValue() : 0);
                hourInfo.put("label", String.format("%02d:00-%02d:59", hour, hour));

                hourlyData.add(hourInfo);
            }

            result.put("data", hourlyData);
            result.put("date", date);
            result.put("total", hourlyData.stream().mapToInt(h -> (Integer) h.get("count")).sum());

        } catch (Exception e) {
            log.error("获取时段预约分析失败", e);
            // 返回默认的24小时数据
            for (int hour = 0; hour < 24; hour++) {
                Map<String, Object> hourInfo = new HashMap<>();
                hourInfo.put("hour", hour);
                hourInfo.put("time", String.format("%02d:00", hour));
                hourInfo.put("count", 0);
                hourInfo.put("label", String.format("%02d:00-%02d:59", hour, hour));
                hourlyData.add(hourInfo);
            }
            result.put("data", hourlyData);
            result.put("date", date);
            result.put("total", 0);
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