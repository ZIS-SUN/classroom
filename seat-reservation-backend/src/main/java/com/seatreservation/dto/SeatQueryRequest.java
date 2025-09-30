package com.seatreservation.dto;

import lombok.Data;
import org.springframework.format.annotation.DateTimeFormat;

import java.time.LocalDate;
import java.time.LocalTime;

@Data
public class SeatQueryRequest {
    
    private String seatNumber;
    
    private Integer floorNumber;
    
    private String area;
    
    private Integer seatTypeId;
    
    private String status;
    
    private Boolean hasPower;
    
    private Boolean hasComputer;
    
    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private LocalDate date;
    
    @DateTimeFormat(pattern = "HH:mm")
    private LocalTime startTime;
    
    @DateTimeFormat(pattern = "HH:mm")
    private LocalTime endTime;
}