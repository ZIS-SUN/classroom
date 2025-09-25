package com.seatreservation.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.seatreservation.entity.SystemSettings;

import java.util.Map;

public interface SystemSettingsService extends IService<SystemSettings> {

    /**
     * 获取所有系统设置
     */
    Map<String, Object> getAllSettings();

    /**
     * 保存指定类型的设置
     */
    void saveSettings(String settingsType, Map<String, Object> settings);

    /**
     * 获取指定类型的设置
     */
    Map<String, Object> getSettingsByType(String settingsType);

    /**
     * 获取单个设置值
     */
    String getSettingValue(String key, String defaultValue);

    /**
     * 设置单个设置值
     */
    void setSettingValue(String key, String value, String type);

    /**
     * 测试邮件发送
     */
    boolean testEmailSending();
}