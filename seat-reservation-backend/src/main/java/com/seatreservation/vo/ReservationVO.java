package com.seatreservation.vo;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

@Data
public class ReservationVO {
    
    private Long id;
    
    private Long userId;
    
    private String userName;
    
    private String userRealName;
    
    private Long seatId;
    
    private String seatNumber;
    
    private String seatArea;
    
    private Integer floorNumber;
    
    private LocalDate reservationDate;
    
    private LocalTime startTime;
    
    private LocalTime endTime;
    
    private String status;
    
    private LocalDateTime checkInTime;
    
    private LocalDateTime checkOutTime;
    
    private BigDecimal totalFee;
    
    private String remark;
    
    private LocalDateTime createdTime;
    
    private LocalDateTime updatedTime;
    
    // 预约时长（小时）
    private Double duration;
    
    // 是否可以签到
    private Boolean canCheckIn;
    
    // 是否可以签退
    private Boolean canCheckOut;
    
    // 是否可以取消
    private Boolean canCancel;
}