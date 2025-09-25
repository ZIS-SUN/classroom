package com.seatreservation.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.seatreservation.dto.LoginRequest;
import com.seatreservation.dto.LoginResponse;
import com.seatreservation.dto.RegisterRequest;
import com.seatreservation.entity.User;

public interface UserService extends IService<User> {
    
    LoginResponse login(LoginRequest loginRequest);
    
    void register(RegisterRequest registerRequest);
    
    User getUserById(Long userId);
    
    User getUserByUsername(String username);
    
    /**
     * 分页获取用户列表
     */
    IPage<User> getUserPage(Page<User> page, String role, String status, String keyword);
}