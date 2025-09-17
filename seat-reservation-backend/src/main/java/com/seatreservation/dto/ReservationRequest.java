package com.seatreservation.dto;

import lombok.Data;
import org.springframework.format.annotation.DateTimeFormat;

import javax.validation.constraints.FutureOrPresent;
import javax.validation.constraints.NotNull;
import java.time.LocalDate;
import java.time.LocalTime;

@Data
public class ReservationRequest {
    
    private Long userId; // 用户ID，管理员创建预约时使用
    
    @NotNull(message = "座位ID不能为空")
    private Long seatId;
    
    @NotNull(message = "预约日期不能为空")
    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private LocalDate reservationDate;
    
    @NotNull(message = "开始时间不能为空")
    @DateTimeFormat(pattern = "HH:mm")
    private LocalTime startTime;
    
    @NotNull(message = "结束时间不能为空")
    @DateTimeFormat(pattern = "HH:mm")
    private LocalTime endTime;
    
    private String remark;
}