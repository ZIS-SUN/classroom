package com.seatreservation.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.seatreservation.entity.SystemSettings;
import com.seatreservation.mapper.SystemSettingsMapper;
import com.seatreservation.service.SystemSettingsService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
public class SystemSettingsServiceImpl extends ServiceImpl<SystemSettingsMapper, SystemSettings> implements SystemSettingsService {

    @Autowired
    private ObjectMapper objectMapper;

    @Override
    public Map<String, Object> getAllSettings() {
        Map<String, Object> result = new HashMap<>();

        try {
            // 获取所有设置
            List<SystemSettings> allSettings = list();

            // 按类型分组
            Map<String, Map<String, Object>> groupedSettings = new HashMap<>();

            for (SystemSettings setting : allSettings) {
                String type = setting.getSettingType();
                if (!groupedSettings.containsKey(type)) {
                    groupedSettings.put(type, new HashMap<>());
                }

                // 将JSON字符串转换为对象
                try {
                    Object value = objectMapper.readValue(setting.getSettingValue(), Object.class);
                    groupedSettings.get(type).put(setting.getSettingKey(), value);
                } catch (Exception e) {
                    // 如果不是JSON，直接存储字符串值
                    groupedSettings.get(type).put(setting.getSettingKey(), setting.getSettingValue());
                }
            }

            // 为每个类型设置默认值（如果没有设置）
            setDefaultSettings(result);

            result.putAll(groupedSettings);

        } catch (Exception e) {
            log.error("获取系统设置失败", e);
            // 返回默认设置
            setDefaultSettings(result);
        }

        return result;
    }

    @Override
    public void saveSettings(String settingsType, Map<String, Object> settings) {
        try {
            for (Map.Entry<String, Object> entry : settings.entrySet()) {
                String key = entry.getKey();
                Object value = entry.getValue();

                // 将值转换为JSON字符串
                String jsonValue;
                if (value instanceof String) {
                    jsonValue = (String) value;
                } else {
                    jsonValue = objectMapper.writeValueAsString(value);
                }

                // 查找现有设置
                QueryWrapper<SystemSettings> query = new QueryWrapper<>();
                query.eq("setting_key", key).eq("setting_type", settingsType);
                SystemSettings existingSetting = getOne(query);

                if (existingSetting != null) {
                    // 更新现有设置
                    existingSetting.setSettingValue(jsonValue);
                    existingSetting.setUpdatedTime(LocalDateTime.now());
                    updateById(existingSetting);
                } else {
                    // 创建新设置
                    SystemSettings newSetting = new SystemSettings();
                    newSetting.setSettingKey(key);
                    newSetting.setSettingValue(jsonValue);
                    newSetting.setSettingType(settingsType);
                    newSetting.setDescription(settingsType + "设置 - " + key);
                    newSetting.setCreatedTime(LocalDateTime.now());
                    newSetting.setUpdatedTime(LocalDateTime.now());
                    save(newSetting);
                }
            }

            log.info("保存{}设置成功: {}", settingsType, settings);

        } catch (Exception e) {
            log.error("保存{}设置失败", settingsType, e);
            throw new RuntimeException("保存设置失败: " + e.getMessage());
        }
    }

    @Override
    public Map<String, Object> getSettingsByType(String settingsType) {
        Map<String, Object> result = new HashMap<>();

        try {
            QueryWrapper<SystemSettings> query = new QueryWrapper<>();
            query.eq("setting_type", settingsType);
            List<SystemSettings> settings = list(query);

            for (SystemSettings setting : settings) {
                try {
                    Object value = objectMapper.readValue(setting.getSettingValue(), Object.class);
                    result.put(setting.getSettingKey(), value);
                } catch (Exception e) {
                    result.put(setting.getSettingKey(), setting.getSettingValue());
                }
            }

        } catch (Exception e) {
            log.error("获取{}设置失败", settingsType, e);
        }

        return result;
    }

    @Override
    public String getSettingValue(String key, String defaultValue) {
        try {
            QueryWrapper<SystemSettings> query = new QueryWrapper<>();
            query.eq("setting_key", key);
            SystemSettings setting = getOne(query);

            return setting != null ? setting.getSettingValue() : defaultValue;

        } catch (Exception e) {
            log.error("获取设置值失败: {}", key, e);
            return defaultValue;
        }
    }

    @Override
    public void setSettingValue(String key, String value, String type) {
        try {
            QueryWrapper<SystemSettings> query = new QueryWrapper<>();
            query.eq("setting_key", key);
            SystemSettings existingSetting = getOne(query);

            if (existingSetting != null) {
                existingSetting.setSettingValue(value);
                existingSetting.setUpdatedTime(LocalDateTime.now());
                updateById(existingSetting);
            } else {
                SystemSettings newSetting = new SystemSettings();
                newSetting.setSettingKey(key);
                newSetting.setSettingValue(value);
                newSetting.setSettingType(type);
                newSetting.setDescription(type + "设置 - " + key);
                newSetting.setCreatedTime(LocalDateTime.now());
                newSetting.setUpdatedTime(LocalDateTime.now());
                save(newSetting);
            }

        } catch (Exception e) {
            log.error("设置配置值失败: {} = {}", key, value, e);
            throw new RuntimeException("设置配置值失败: " + e.getMessage());
        }
    }

    @Override
    public boolean testEmailSending() {
        try {
            // 获取邮件设置
            Map<String, Object> emailSettings = getSettingsByType("email");

            // 检查邮件是否启用
            Boolean enableEmail = (Boolean) emailSettings.get("enableEmail");
            if (enableEmail == null || !enableEmail) {
                log.warn("邮件功能未启用");
                return false;
            }

            // 这里可以添加实际的邮件发送逻辑
            log.info("测试邮件发送 - 邮件设置: {}", emailSettings);

            // 模拟邮件发送成功
            return true;

        } catch (Exception e) {
            log.error("测试邮件发送失败", e);
            return false;
        }
    }

    private void setDefaultSettings(Map<String, Object> settingsMap) {
        // 基础设置默认值
        if (!settingsMap.containsKey("basic")) {
            Map<String, Object> basicDefaults = new HashMap<>();
            basicDefaults.put("systemName", "自习室座位预约系统");
            basicDefaults.put("systemDescription", "智能化的自习室座位预约管理系统");
            basicDefaults.put("systemVersion", "1.0.0");
            basicDefaults.put("contactEmail", "admin@seatreservation.com");
            basicDefaults.put("contactPhone", "400-123-4567");
            basicDefaults.put("systemEnabled", true);
            basicDefaults.put("maintenanceMode", false);
            settingsMap.put("basic", basicDefaults);
        }

        // 预约设置默认值
        if (!settingsMap.containsKey("reservation")) {
            Map<String, Object> reservationDefaults = new HashMap<>();
            reservationDefaults.put("maxHours", 8);
            reservationDefaults.put("advanceDays", 7);
            reservationDefaults.put("cancelHours", 2);
            reservationDefaults.put("autoConfirm", false);
            reservationDefaults.put("allowDuplicate", false);
            reservationDefaults.put("enableReminder", true);
            reservationDefaults.put("reminderMinutes", 30);
            settingsMap.put("reservation", reservationDefaults);
        }

        // 时间设置默认值
        if (!settingsMap.containsKey("schedule")) {
            Map<String, Object> scheduleDefaults = new HashMap<>();
            scheduleDefaults.put("openTime", "08:00");
            scheduleDefaults.put("closeTime", "22:00");
            scheduleDefaults.put("restDays", new String[]{});
            scheduleDefaults.put("holidayMode", false);
            scheduleDefaults.put("holidays", new String[]{});
            settingsMap.put("schedule", scheduleDefaults);
        }

        // 支付设置默认值
        if (!settingsMap.containsKey("payment")) {
            Map<String, Object> paymentDefaults = new HashMap<>();
            paymentDefaults.put("enablePayment", true);
            paymentDefaults.put("defaultHourlyRate", 5.0);
            paymentDefaults.put("minimumAmount", 1.0);
            paymentDefaults.put("enableWallet", true);
            paymentDefaults.put("freeTrialMinutes", 30);
            paymentDefaults.put("paymentMethods", new String[]{"wallet", "alipay", "wechat"});
            settingsMap.put("payment", paymentDefaults);
        }

        // 邮件设置默认值
        if (!settingsMap.containsKey("email")) {
            Map<String, Object> emailDefaults = new HashMap<>();
            emailDefaults.put("enableEmail", false);
            emailDefaults.put("smtpHost", "");
            emailDefaults.put("smtpPort", 587);
            emailDefaults.put("senderEmail", "");
            emailDefaults.put("senderPassword", "");
            emailDefaults.put("enableSSL", true);
            emailDefaults.put("template", "default");
            settingsMap.put("email", emailDefaults);
        }

        // 安全设置默认值
        if (!settingsMap.containsKey("security")) {
            Map<String, Object> securityDefaults = new HashMap<>();
            securityDefaults.put("maxLoginAttempts", 5);
            securityDefaults.put("lockoutMinutes", 30);
            securityDefaults.put("minPasswordLength", 6);
            securityDefaults.put("passwordRequirements", new String[]{"lowercase", "numbers"});
            securityDefaults.put("sessionTimeout", 120);
            securityDefaults.put("enableCaptcha", false);
            securityDefaults.put("enableIPWhitelist", false);
            securityDefaults.put("allowedIPs", "");
            settingsMap.put("security", securityDefaults);
        }
    }
}