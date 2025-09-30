package com.seatreservation.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 充值记录实体类
 */
@Data
@TableName("recharge_record")
public class RechargeRecord {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private Long userId;
    
    private String orderNo;
    
    private BigDecimal amount;
    
    private BigDecimal bonusAmount = BigDecimal.ZERO;
    
    private String paymentMethod; // WECHAT, ALIPAY, BANK_CARD
    
    private String paymentStatus; // PENDING, SUCCESS, FAILED, CANCELLED
    
    private String thirdPartyOrderNo;
    
    private String remark;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdTime;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updatedTime;
}