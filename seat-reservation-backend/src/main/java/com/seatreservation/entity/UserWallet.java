package com.seatreservation.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 用户钱包实体类
 */
@Data
@TableName("user_wallet")
public class UserWallet {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private Long userId;
    
    private BigDecimal balance = BigDecimal.ZERO;
    
    private BigDecimal totalRecharge = BigDecimal.ZERO;
    
    private BigDecimal totalConsume = BigDecimal.ZERO;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdTime;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updatedTime;
}