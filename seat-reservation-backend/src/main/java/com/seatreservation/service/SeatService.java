package com.seatreservation.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.seatreservation.dto.SeatQueryRequest;
import com.seatreservation.entity.Seat;
import com.seatreservation.vo.SeatVO;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

public interface SeatService extends IService<Seat> {
    
    /**
     * 分页查询座位
     */
    IPage<SeatVO> getSeatPage(Page<Seat> page, SeatQueryRequest request);
    
    /**
     * 获取所有座位类型
     */
    List<com.seatreservation.entity.SeatType> getAllSeatTypes();
    
    /**
     * 根据条件查询可用座位
     */
    List<SeatVO> getAvailableSeats(String area, Integer floorNumber, Integer seatTypeId, 
                                   LocalDate date, LocalTime startTime, LocalTime endTime);
    
    /**
     * 获取座位详情
     */
    SeatVO getSeatDetail(Long seatId);
    
    /**
     * 更新座位状态
     */
    void updateSeatStatus(Long seatId, String status);

    /**
     * 检查座位是否有未完成的预约
     */
    boolean hasActiveReservations(Long seatId);
}