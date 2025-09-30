package com.seatreservation.vo;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class SeatVO {
    
    private Long id;
    
    private String seatNumber;
    
    private Integer floorNumber;
    
    private String area;
    
    private Integer seatTypeId;
    
    private String seatTypeName;
    
    private BigDecimal hourlyRate;
    
    private Integer positionX;
    
    private Integer positionY;
    
    private String status;
    
    private Boolean hasPower;
    
    private Boolean hasComputer;
    
    private String description;
    
    private LocalDateTime createdTime;
    
    private LocalDateTime updatedTime;
    
    // 是否可预约（基于时间段判断）
    private Boolean available;
    
    // 当前预约信息（如果有）
    private String currentReservation;
}