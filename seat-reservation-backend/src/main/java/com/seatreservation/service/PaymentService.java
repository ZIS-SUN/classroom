package com.seatreservation.service;

import com.seatreservation.entity.PaymentRecord;
import com.seatreservation.entity.RechargeRecord;
import com.seatreservation.entity.UserWallet;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

/**
 * 支付服务接口
 */
public interface PaymentService {

    /**
     * 获取用户钱包信息
     */
    UserWallet getUserWallet(Long userId);

    /**
     * 创建支付订单
     */
    PaymentRecord createPaymentOrder(Long userId, Long reservationId, BigDecimal amount, String paymentMethod);

    /**
     * 处理支付
     */
    Map<String, Object> processPayment(String orderNo, String paymentMethod);

    /**
     * 支付成功回调
     */
    boolean paymentSuccess(String orderNo, String thirdPartyOrderNo);

    /**
     * 支付失败回调
     */
    boolean paymentFailed(String orderNo, String reason);

    /**
     * 创建充值订单
     */
    RechargeRecord createRechargeOrder(Long userId, BigDecimal amount, String paymentMethod);

    /**
     * 处理充值
     */
    Map<String, Object> processRecharge(String orderNo, String paymentMethod);

    /**
     * 充值成功回调
     */
    boolean rechargeSuccess(String orderNo, String thirdPartyOrderNo);

    /**
     * 充值失败回调
     */
    boolean rechargeFailed(String orderNo, String reason);

    /**
     * 退款
     */
    boolean refund(String orderNo, BigDecimal refundAmount, String reason);

    /**
     * 获取用户支付记录
     */
    List<PaymentRecord> getUserPaymentRecords(Long userId, int current, int size);

    /**
     * 获取用户充值记录
     */
    List<RechargeRecord> getUserRechargeRecords(Long userId, int current, int size);

    /**
     * 钱包余额支付
     */
    boolean walletPay(Long userId, BigDecimal amount, String orderNo);

    /**
     * 模拟第三方支付
     */
    Map<String, Object> mockThirdPartyPayment(String orderNo, BigDecimal amount, String paymentMethod);
}