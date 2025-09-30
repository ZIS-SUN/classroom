package com.seatreservation.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 支付记录实体类
 */
@Data
@TableName("payment_record")
public class PaymentRecord {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private Long userId;
    
    private Long reservationId;
    
    private String orderNo;
    
    private BigDecimal amount;
    
    private String paymentMethod; // WALLET, WECHAT, ALIPAY, BANK_CARD
    
    private String paymentStatus; // PENDING, SUCCESS, FAILED, CANCELLED, REFUNDED
    
    private String thirdPartyOrderNo;
    
    private BigDecimal refundAmount = BigDecimal.ZERO;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime refundTime;
    
    private String remark;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdTime;
    
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updatedTime;
}