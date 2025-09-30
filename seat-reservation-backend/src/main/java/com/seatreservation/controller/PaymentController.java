package com.seatreservation.controller;

import com.seatreservation.entity.PaymentRecord;
import com.seatreservation.entity.RechargeRecord;
import com.seatreservation.entity.UserWallet;
import com.seatreservation.service.PaymentService;
import com.seatreservation.utils.Result;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import java.math.BigDecimal;
import java.util.*;

@Slf4j
@RestController
@RequestMapping("/payment")
public class PaymentController {

    @Autowired
    private PaymentService paymentService;

    /**
     * 获取用户钱包信息
     */
    @GetMapping("/wallet")
    public Result<UserWallet> getUserWallet(HttpServletRequest request) {
        try {
            Long userId = getUserIdFromRequest(request);
            UserWallet wallet = paymentService.getUserWallet(userId);
            return Result.success("查询成功", wallet);
        } catch (Exception e) {
            log.error("获取钱包信息失败: {}", e.getMessage());
            return Result.error("查询失败: " + e.getMessage());
        }
    }

    /**
     * 创建支付订单
     */
    @PostMapping("/create-order")
    public Result<PaymentRecord> createPaymentOrder(@RequestBody Map<String, Object> params, HttpServletRequest request) {
        try {
            Long userId = getUserIdFromRequest(request);
            Long reservationId = Long.parseLong(params.get("reservationId").toString());
            BigDecimal amount = new BigDecimal(params.get("amount").toString());
            String paymentMethod = params.get("paymentMethod").toString();
            
            PaymentRecord record = paymentService.createPaymentOrder(userId, reservationId, amount, paymentMethod);
            return Result.success("创建成功", record);
            
        } catch (Exception e) {
            log.error("创建支付订单失败: {}", e.getMessage());
            return Result.error("创建失败: " + e.getMessage());
        }
    }

    /**
     * 处理支付
     */
    @PostMapping("/process")
    public Result<Map<String, Object>> processPayment(@RequestBody Map<String, String> params) {
        try {
            String orderNo = params.get("orderNo");
            String paymentMethod = params.get("paymentMethod");
            
            Map<String, Object> result = paymentService.processPayment(orderNo, paymentMethod);
            
            if ((Boolean) result.get("success")) {
                return Result.success("支付处理成功", result);
            } else {
                return Result.error(result.get("message").toString());
            }
            
        } catch (Exception e) {
            log.error("处理支付失败: {}", e.getMessage());
            return Result.error("支付处理失败: " + e.getMessage());
        }
    }

    /**
     * 支付成功回调 (模拟第三方支付回调)
     */
    @PostMapping("/callback/success")
    public Result<String> paymentSuccessCallback(@RequestBody Map<String, String> params) {
        try {
            String orderNo = params.get("orderNo");
            String thirdPartyOrderNo = params.get("thirdPartyOrderNo");
            
            boolean success = paymentService.paymentSuccess(orderNo, thirdPartyOrderNo);
            
            if (success) {
                return Result.success("回调处理成功");
            } else {
                return Result.error("回调处理失败");
            }
            
        } catch (Exception e) {
            log.error("支付成功回调失败: {}", e.getMessage());
            return Result.error("回调处理异常: " + e.getMessage());
        }
    }

    /**
     * 支付失败回调 (模拟第三方支付回调)
     */
    @PostMapping("/callback/failed")
    public Result<String> paymentFailedCallback(@RequestBody Map<String, String> params) {
        try {
            String orderNo = params.get("orderNo");
            String reason = params.get("reason");
            
            boolean success = paymentService.paymentFailed(orderNo, reason);
            
            if (success) {
                return Result.success("回调处理成功");
            } else {
                return Result.error("回调处理失败");
            }
            
        } catch (Exception e) {
            log.error("支付失败回调失败: {}", e.getMessage());
            return Result.error("回调处理异常: " + e.getMessage());
        }
    }

    /**
     * 创建充值订单
     */
    @PostMapping("/recharge/create-order")
    public Result<RechargeRecord> createRechargeOrder(@RequestBody Map<String, Object> params, HttpServletRequest request) {
        try {
            Long userId = getUserIdFromRequest(request);
            BigDecimal amount = new BigDecimal(params.get("amount").toString());
            String paymentMethod = params.get("paymentMethod").toString();
            
            RechargeRecord record = paymentService.createRechargeOrder(userId, amount, paymentMethod);
            return Result.success("创建成功", record);
            
        } catch (Exception e) {
            log.error("创建充值订单失败: {}", e.getMessage());
            return Result.error("创建失败: " + e.getMessage());
        }
    }

    /**
     * 处理充值
     */
    @PostMapping("/recharge/process")
    public Result<Map<String, Object>> processRecharge(@RequestBody Map<String, String> params) {
        try {
            String orderNo = params.get("orderNo");
            String paymentMethod = params.get("paymentMethod");
            
            Map<String, Object> result = paymentService.processRecharge(orderNo, paymentMethod);
            
            if ((Boolean) result.get("success")) {
                // 模拟充值成功
                paymentService.rechargeSuccess(orderNo, result.get("thirdPartyOrderNo").toString());
                return Result.success("充值成功", result);
            } else {
                return Result.error(result.get("message").toString());
            }
            
        } catch (Exception e) {
            log.error("处理充值失败: {}", e.getMessage());
            return Result.error("充值处理失败: " + e.getMessage());
        }
    }

    /**
     * 申请退款
     */
    @PostMapping("/refund")
    public Result<String> refund(@RequestBody Map<String, Object> params) {
        try {
            String orderNo = params.get("orderNo").toString();
            BigDecimal refundAmount = new BigDecimal(params.get("refundAmount").toString());
            String reason = params.get("reason").toString();
            
            boolean success = paymentService.refund(orderNo, refundAmount, reason);
            
            if (success) {
                return Result.success("退款成功");
            } else {
                return Result.error("退款失败");
            }
            
        } catch (Exception e) {
            log.error("申请退款失败: {}", e.getMessage());
            return Result.error("退款失败: " + e.getMessage());
        }
    }

    /**
     * 获取用户支付记录
     */
    @GetMapping("/records")
    public Result<List<PaymentRecord>> getUserPaymentRecords(
            @RequestParam(defaultValue = "1") int current,
            @RequestParam(defaultValue = "10") int size,
            HttpServletRequest request) {
        try {
            Long userId = getUserIdFromRequest(request);
            List<PaymentRecord> records = paymentService.getUserPaymentRecords(userId, current, size);
            return Result.success("查询成功", records);
        } catch (Exception e) {
            log.error("获取支付记录失败: {}", e.getMessage());
            return Result.error("查询失败: " + e.getMessage());
        }
    }

    /**
     * 获取用户充值记录
     */
    @GetMapping("/recharge/records")
    public Result<List<RechargeRecord>> getUserRechargeRecords(
            @RequestParam(defaultValue = "1") int current,
            @RequestParam(defaultValue = "10") int size,
            HttpServletRequest request) {
        try {
            Long userId = getUserIdFromRequest(request);
            List<RechargeRecord> records = paymentService.getUserRechargeRecords(userId, current, size);
            return Result.success("查询成功", records);
        } catch (Exception e) {
            log.error("获取充值记录失败: {}", e.getMessage());
            return Result.error("查询失败: " + e.getMessage());
        }
    }

    /**
     * 获取充值优惠信息
     */
    @GetMapping("/recharge/bonus-info")
    public Result<Map<String, Object>> getRechargeBonus() {
        try {
            List<Map<String, Object>> rules = new ArrayList<>();
            Map<String, Object> rule1 = new HashMap<>();
            rule1.put("amount", 50);
            rule1.put("bonus", 5);
            rule1.put("description", "充值50元送5元");
            rules.add(rule1);
            
            Map<String, Object> rule2 = new HashMap<>();
            rule2.put("amount", 100);
            rule2.put("bonus", 10);
            rule2.put("description", "充值100元送10元");
            rules.add(rule2);
            
            Map<String, Object> rule3 = new HashMap<>();
            rule3.put("amount", 200);
            rule3.put("bonus", 30);
            rule3.put("description", "充值200元送30元");
            rules.add(rule3);
            
            Map<String, Object> bonusInfo = new HashMap<>();
            bonusInfo.put("rules", rules);
            bonusInfo.put("description", "充值越多送的越多，赠送金额实时到账！");
            return Result.success("查询成功", bonusInfo);
        } catch (Exception e) {
            log.error("获取充值优惠信息失败: {}", e.getMessage());
            return Result.error("查询失败: " + e.getMessage());
        }
    }

    // 从请求中获取用户ID的辅助方法
    private Long getUserIdFromRequest(HttpServletRequest request) {
        // 这里应该从JWT token或session中获取用户ID
        // 为了简化，暂时从header中获取
        String userIdStr = request.getHeader("userId");
        if (userIdStr != null) {
            return Long.parseLong(userIdStr);
        }
        
        // 如果没有提供userId，返回默认测试用户ID
        return 2L; // 测试用户ID
    }
}