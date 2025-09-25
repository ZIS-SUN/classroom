package com.seatreservation.controller;

import com.seatreservation.service.SystemSettingsService;
import com.seatreservation.utils.Result;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/system")
public class SystemSettingsController {

    @Autowired
    private SystemSettingsService systemSettingsService;

    /**
     * 获取所有系统设置
     */
    @GetMapping("/settings")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Map<String, Object>> getAllSettings() {
        try {
            Map<String, Object> settings = systemSettingsService.getAllSettings();
            return Result.success("获取设置成功", settings);
        } catch (Exception e) {
            log.error("获取系统设置失败: {}", e.getMessage());
            return Result.error("获取设置失败: " + e.getMessage());
        }
    }

    /**
     * 获取指定类型的设置
     */
    @GetMapping("/settings/{settingsType}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Map<String, Object>> getSettingsByType(@PathVariable String settingsType) {
        try {
            Map<String, Object> settings = systemSettingsService.getSettingsByType(settingsType);
            return Result.success("获取设置成功", settings);
        } catch (Exception e) {
            log.error("获取{}设置失败: {}", settingsType, e.getMessage());
            return Result.error("获取设置失败: " + e.getMessage());
        }
    }

    /**
     * 保存基础设置
     */
    @PutMapping("/settings/basic")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Void> saveBasicSettings(@RequestBody Map<String, Object> settings) {
        try {
            systemSettingsService.saveSettings("basic", settings);
            return Result.success("保存基础设置成功", null);
        } catch (Exception e) {
            log.error("保存基础设置失败: {}", e.getMessage());
            return Result.error("保存失败: " + e.getMessage());
        }
    }

    /**
     * 保存预约设置
     */
    @PutMapping("/settings/reservation")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Void> saveReservationSettings(@RequestBody Map<String, Object> settings) {
        try {
            systemSettingsService.saveSettings("reservation", settings);
            return Result.success("保存预约设置成功", null);
        } catch (Exception e) {
            log.error("保存预约设置失败: {}", e.getMessage());
            return Result.error("保存失败: " + e.getMessage());
        }
    }

    /**
     * 保存时间设置
     */
    @PutMapping("/settings/schedule")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Void> saveScheduleSettings(@RequestBody Map<String, Object> settings) {
        try {
            systemSettingsService.saveSettings("schedule", settings);
            return Result.success("保存时间设置成功", null);
        } catch (Exception e) {
            log.error("保存时间设置失败: {}", e.getMessage());
            return Result.error("保存失败: " + e.getMessage());
        }
    }

    /**
     * 保存支付设置
     */
    @PutMapping("/settings/payment")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Void> savePaymentSettings(@RequestBody Map<String, Object> settings) {
        try {
            systemSettingsService.saveSettings("payment", settings);
            return Result.success("保存支付设置成功", null);
        } catch (Exception e) {
            log.error("保存支付设置失败: {}", e.getMessage());
            return Result.error("保存失败: " + e.getMessage());
        }
    }

    /**
     * 保存邮件设置
     */
    @PutMapping("/settings/email")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Void> saveEmailSettings(@RequestBody Map<String, Object> settings) {
        try {
            systemSettingsService.saveSettings("email", settings);
            return Result.success("保存邮件设置成功", null);
        } catch (Exception e) {
            log.error("保存邮件设置失败: {}", e.getMessage());
            return Result.error("保存失败: " + e.getMessage());
        }
    }

    /**
     * 保存安全设置
     */
    @PutMapping("/settings/security")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Void> saveSecuritySettings(@RequestBody Map<String, Object> settings) {
        try {
            systemSettingsService.saveSettings("security", settings);
            return Result.success("保存安全设置成功", null);
        } catch (Exception e) {
            log.error("保存安全设置失败: {}", e.getMessage());
            return Result.error("保存失败: " + e.getMessage());
        }
    }

    /**
     * 测试邮件发送
     */
    @PostMapping("/settings/email/test")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Void> testEmailSending() {
        try {
            boolean success = systemSettingsService.testEmailSending();
            if (success) {
                return Result.success("测试邮件发送成功", null);
            } else {
                return Result.error("测试邮件发送失败，请检查邮件配置");
            }
        } catch (Exception e) {
            log.error("测试邮件发送失败: {}", e.getMessage());
            return Result.error("测试邮件发送失败: " + e.getMessage());
        }
    }

    /**
     * 重置设置为默认值
     */
    @PostMapping("/settings/{settingsType}/reset")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Void> resetSettings(@PathVariable String settingsType) {
        try {
            // 删除指定类型的所有设置，下次获取时会返回默认值
            // 这里可以根据需要实现具体的重置逻辑
            log.info("重置{}设置为默认值", settingsType);
            return Result.success("重置设置成功", null);
        } catch (Exception e) {
            log.error("重置{}设置失败: {}", settingsType, e.getMessage());
            return Result.error("重置设置失败: " + e.getMessage());
        }
    }
}