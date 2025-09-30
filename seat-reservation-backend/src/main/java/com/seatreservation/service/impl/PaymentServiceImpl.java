package com.seatreservation.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.seatreservation.entity.PaymentRecord;
import com.seatreservation.entity.RechargeRecord;
import com.seatreservation.entity.Reservation;
import com.seatreservation.entity.UserWallet;
import com.seatreservation.mapper.PaymentRecordMapper;
import com.seatreservation.mapper.RechargeRecordMapper;
import com.seatreservation.mapper.ReservationMapper;
import com.seatreservation.mapper.UserWalletMapper;
import com.seatreservation.service.PaymentService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Random;

@Slf4j
@Service
@Transactional
public class PaymentServiceImpl implements PaymentService {

    @Autowired
    private UserWalletMapper userWalletMapper;

    @Autowired
    private PaymentRecordMapper paymentRecordMapper;

    @Autowired
    private RechargeRecordMapper rechargeRecordMapper;

    @Autowired
    private ReservationMapper reservationMapper;

    private static final Random random = new Random();

    @Override
    public UserWallet getUserWallet(Long userId) {
        QueryWrapper<UserWallet> query = new QueryWrapper<>();
        query.eq("user_id", userId);
        UserWallet wallet = userWalletMapper.selectOne(query);
        
        if (wallet == null) {
            // 如果用户没有钱包，自动创建
            wallet = new UserWallet();
            wallet.setUserId(userId);
            wallet.setBalance(BigDecimal.ZERO);
            wallet.setTotalRecharge(BigDecimal.ZERO);
            wallet.setTotalConsume(BigDecimal.ZERO);
            wallet.setCreatedTime(LocalDateTime.now());
            wallet.setUpdatedTime(LocalDateTime.now());
            userWalletMapper.insert(wallet);
        }
        
        return wallet;
    }

    @Override
    public PaymentRecord createPaymentOrder(Long userId, Long reservationId, BigDecimal amount, String paymentMethod) {
        PaymentRecord record = new PaymentRecord();
        record.setUserId(userId);
        record.setReservationId(reservationId);
        record.setOrderNo(generateOrderNo("PAY"));
        record.setAmount(amount);
        record.setPaymentMethod(paymentMethod);
        record.setPaymentStatus("PENDING");
        record.setCreatedTime(LocalDateTime.now());
        record.setUpdatedTime(LocalDateTime.now());
        
        paymentRecordMapper.insert(record);
        return record;
    }

    @Override
    public Map<String, Object> processPayment(String orderNo, String paymentMethod) {
        Map<String, Object> result = new HashMap<>();
        
        PaymentRecord record = getPaymentRecordByOrderNo(orderNo);
        if (record == null) {
            result.put("success", false);
            result.put("message", "支付订单不存在");
            return result;
        }
        
        if (!"PENDING".equals(record.getPaymentStatus())) {
            result.put("success", false);
            result.put("message", "订单状态异常");
            return result;
        }
        
        if ("WALLET".equals(paymentMethod)) {
            // 钱包支付
            return processWalletPayment(record);
        } else {
            // 第三方支付
            return mockThirdPartyPayment(orderNo, record.getAmount(), paymentMethod);
        }
    }

    private Map<String, Object> processWalletPayment(PaymentRecord record) {
        Map<String, Object> result = new HashMap<>();
        
        try {
            // 检查余额并扣款
            int affected = userWalletMapper.deductBalance(record.getUserId(), record.getAmount());
            
            if (affected > 0) {
                // 更新支付记录
                record.setPaymentStatus("SUCCESS");
                record.setUpdatedTime(LocalDateTime.now());
                paymentRecordMapper.updateById(record);
                
                // 更新预约状态：支付成功 -> RESERVED
                updateReservationStatus(record.getReservationId(), "RESERVED", "PAID");
                
                result.put("success", true);
                result.put("message", "支付成功");
                result.put("orderNo", record.getOrderNo());
            } else {
                result.put("success", false);
                result.put("message", "余额不足");
            }
            
        } catch (Exception e) {
            log.error("钱包支付失败: {}", e.getMessage());
            result.put("success", false);
            result.put("message", "支付失败");
        }
        
        return result;
    }

    @Override
    public Map<String, Object> mockThirdPartyPayment(String orderNo, BigDecimal amount, String paymentMethod) {
        Map<String, Object> result = new HashMap<>();
        
        try {
            // 模拟支付处理时间
            Thread.sleep(1000);
            
            // 90% 成功率
            boolean success = random.nextInt(10) < 9;
            
            if (success) {
                String thirdPartyOrderNo = generateThirdPartyOrderNo(paymentMethod);
                paymentSuccess(orderNo, thirdPartyOrderNo);
                
                result.put("success", true);
                result.put("message", "支付成功");
                result.put("orderNo", orderNo);
                result.put("thirdPartyOrderNo", thirdPartyOrderNo);
                result.put("paymentUrl", "https://mockpay.example.com/pay?order=" + thirdPartyOrderNo);
            } else {
                paymentFailed(orderNo, "模拟支付失败");
                result.put("success", false);
                result.put("message", "支付失败");
            }
            
        } catch (Exception e) {
            log.error("模拟第三方支付失败: {}", e.getMessage());
            result.put("success", false);
            result.put("message", "支付异常");
        }
        
        return result;
    }

    @Override
    public boolean paymentSuccess(String orderNo, String thirdPartyOrderNo) {
        PaymentRecord record = getPaymentRecordByOrderNo(orderNo);
        if (record == null) {
            return false;
        }
        
        record.setPaymentStatus("SUCCESS");
        record.setThirdPartyOrderNo(thirdPartyOrderNo);
        record.setUpdatedTime(LocalDateTime.now());
        paymentRecordMapper.updateById(record);
        
        // 更新预约状态：支付成功 -> RESERVED
        updateReservationStatus(record.getReservationId(), "RESERVED", "PAID");
        
        log.info("支付成功: orderNo={}, thirdPartyOrderNo={}", orderNo, thirdPartyOrderNo);
        return true;
    }

    @Override
    public boolean paymentFailed(String orderNo, String reason) {
        PaymentRecord record = getPaymentRecordByOrderNo(orderNo);
        if (record == null) {
            return false;
        }
        
        record.setPaymentStatus("FAILED");
        record.setRemark(reason);
        record.setUpdatedTime(LocalDateTime.now());
        paymentRecordMapper.updateById(record);
        
        log.info("支付失败: orderNo={}, reason={}", orderNo, reason);
        return true;
    }

    @Override
    public RechargeRecord createRechargeOrder(Long userId, BigDecimal amount, String paymentMethod) {
        RechargeRecord record = new RechargeRecord();
        record.setUserId(userId);
        record.setOrderNo(generateOrderNo("RCH"));
        record.setAmount(amount);
        
        // 计算赠送金额 (充值优惠)
        BigDecimal bonusAmount = calculateBonusAmount(amount);
        record.setBonusAmount(bonusAmount);
        
        record.setPaymentMethod(paymentMethod);
        record.setPaymentStatus("PENDING");
        record.setCreatedTime(LocalDateTime.now());
        record.setUpdatedTime(LocalDateTime.now());
        
        rechargeRecordMapper.insert(record);
        return record;
    }

    @Override
    public Map<String, Object> processRecharge(String orderNo, String paymentMethod) {
        return mockThirdPartyPayment(orderNo, getRechargeAmount(orderNo), paymentMethod);
    }

    @Override
    public boolean rechargeSuccess(String orderNo, String thirdPartyOrderNo) {
        RechargeRecord record = getRechargeRecordByOrderNo(orderNo);
        if (record == null) {
            return false;
        }
        
        record.setPaymentStatus("SUCCESS");
        record.setThirdPartyOrderNo(thirdPartyOrderNo);
        record.setUpdatedTime(LocalDateTime.now());
        rechargeRecordMapper.updateById(record);
        
        // 增加钱包余额
        BigDecimal totalAmount = record.getAmount().add(record.getBonusAmount());
        userWalletMapper.addBalance(record.getUserId(), totalAmount, record.getAmount());
        
        log.info("充值成功: orderNo={}, amount={}, bonus={}", orderNo, record.getAmount(), record.getBonusAmount());
        return true;
    }

    @Override
    public boolean rechargeFailed(String orderNo, String reason) {
        RechargeRecord record = getRechargeRecordByOrderNo(orderNo);
        if (record == null) {
            return false;
        }
        
        record.setPaymentStatus("FAILED");
        record.setRemark(reason);
        record.setUpdatedTime(LocalDateTime.now());
        rechargeRecordMapper.updateById(record);
        
        log.info("充值失败: orderNo={}, reason={}", orderNo, reason);
        return true;
    }

    @Override
    public boolean refund(String orderNo, BigDecimal refundAmount, String reason) {
        PaymentRecord record = getPaymentRecordByOrderNo(orderNo);
        if (record == null || !"SUCCESS".equals(record.getPaymentStatus())) {
            return false;
        }
        
        try {
            // 退款到钱包
            userWalletMapper.refundToWallet(record.getUserId(), refundAmount);
            
            // 更新支付记录
            record.setPaymentStatus("REFUNDED");
            record.setRefundAmount(refundAmount);
            record.setRefundTime(LocalDateTime.now());
            record.setRemark(reason);
            record.setUpdatedTime(LocalDateTime.now());
            paymentRecordMapper.updateById(record);
            
            log.info("退款成功: orderNo={}, refundAmount={}", orderNo, refundAmount);
            return true;
            
        } catch (Exception e) {
            log.error("退款失败: {}", e.getMessage());
            return false;
        }
    }

    @Override
    public List<PaymentRecord> getUserPaymentRecords(Long userId, int current, int size) {
        QueryWrapper<PaymentRecord> query = new QueryWrapper<>();
        query.eq("user_id", userId).orderByDesc("created_time");
        Page<PaymentRecord> page = new Page<>(current, size);
        return paymentRecordMapper.selectPage(page, query).getRecords();
    }

    @Override
    public List<RechargeRecord> getUserRechargeRecords(Long userId, int current, int size) {
        QueryWrapper<RechargeRecord> query = new QueryWrapper<>();
        query.eq("user_id", userId).orderByDesc("created_time");
        Page<RechargeRecord> page = new Page<>(current, size);
        return rechargeRecordMapper.selectPage(page, query).getRecords();
    }

    @Override
    public boolean walletPay(Long userId, BigDecimal amount, String orderNo) {
        try {
            int affected = userWalletMapper.deductBalance(userId, amount);
            return affected > 0;
        } catch (Exception e) {
            log.error("钱包支付失败: {}", e.getMessage());
            return false;
        }
    }

    // 辅助方法

    private String generateOrderNo(String prefix) {
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        String randomSuffix = String.format("%04d", random.nextInt(10000));
        return prefix + timestamp + randomSuffix;
    }

    private String generateThirdPartyOrderNo(String paymentMethod) {
        String prefix = "";
        switch (paymentMethod) {
            case "WECHAT":
                prefix = "WX";
                break;
            case "ALIPAY":
                prefix = "ALI";
                break;
            case "BANK_CARD":
                prefix = "BANK";
                break;
            default:
                prefix = "PAY";
        }
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        String randomSuffix = String.format("%06d", random.nextInt(1000000));
        return prefix + timestamp + randomSuffix;
    }

    private PaymentRecord getPaymentRecordByOrderNo(String orderNo) {
        QueryWrapper<PaymentRecord> query = new QueryWrapper<>();
        query.eq("order_no", orderNo);
        return paymentRecordMapper.selectOne(query);
    }

    private RechargeRecord getRechargeRecordByOrderNo(String orderNo) {
        QueryWrapper<RechargeRecord> query = new QueryWrapper<>();
        query.eq("order_no", orderNo);
        return rechargeRecordMapper.selectOne(query);
    }

    private BigDecimal getRechargeAmount(String orderNo) {
        RechargeRecord record = getRechargeRecordByOrderNo(orderNo);
        return record != null ? record.getAmount() : BigDecimal.ZERO;
    }

    private BigDecimal calculateBonusAmount(BigDecimal amount) {
        // 充值优惠规则
        if (amount.compareTo(new BigDecimal("200")) >= 0) {
            return new BigDecimal("30"); // 充值200送30
        } else if (amount.compareTo(new BigDecimal("100")) >= 0) {
            return new BigDecimal("10"); // 充值100送10
        } else if (amount.compareTo(new BigDecimal("50")) >= 0) {
            return new BigDecimal("5"); // 充值50送5
        }
        return BigDecimal.ZERO;
    }

    private void updateReservationStatus(Long reservationId, String status, String paymentStatus) {
        try {
            Reservation reservation = reservationMapper.selectById(reservationId);
            if (reservation != null) {
                reservation.setStatus(status);
                reservation.setUpdatedTime(LocalDateTime.now());
                reservationMapper.updateById(reservation);
            }
        } catch (Exception e) {
            log.error("更新预约状态失败: reservationId={}", reservationId, e);
        }
    }
}
