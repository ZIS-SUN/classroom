package com.seatreservation.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.seatreservation.dto.ReservationRequest;
import com.seatreservation.entity.Reservation;
import com.seatreservation.vo.ReservationVO;

import java.util.List;

public interface ReservationService extends IService<Reservation> {
    
    /**
     * 创建预约
     */
    ReservationVO createReservation(Long userId, ReservationRequest request);
    
    /**
     * 取消预约
     */
    void cancelReservation(Long userId, Long reservationId);
    
    /**
     * 签到
     */
    void checkIn(Long userId, Long reservationId);
    
    /**
     * 签退
     */
    void checkOut(Long userId, Long reservationId);
    
    /**
     * 获取用户预约列表
     */
    IPage<ReservationVO> getUserReservations(Long userId, Page<Reservation> page);
    
    /**
     * 获取预约详情
     */
    ReservationVO getReservationDetail(Long userId, Long reservationId);
    
    /**
     * 管理员获取所有预约列表
     */
    IPage<ReservationVO> getAllReservations(Page<Reservation> page, String status);
    
    /**
     * 管理员获取所有预约列表（支持日期范围过滤）
     */
    IPage<ReservationVO> getAllReservations(Page<Reservation> page, String status, String startDate, String endDate);
    
    /**
     * 管理员获取预约详情
     */
    ReservationVO getReservationDetailByAdmin(Long reservationId);
    
    /**
     * 管理员创建预约
     */
    ReservationVO createReservationByAdmin(ReservationRequest request);
    
    /**
     * 管理员更新预约
     */
    ReservationVO updateReservationByAdmin(Long reservationId, ReservationRequest request);
    
    /**
     * 管理员取消预约
     */
    void cancelReservationByAdmin(Long reservationId);
}