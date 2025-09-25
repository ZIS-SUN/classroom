package com.seatreservation.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("system_settings")
public class SystemSettings {
    @TableId(type = IdType.AUTO)
    private Long id;

    private String settingKey;
    private String settingValue;
    private String settingType;
    private String description;
    private LocalDateTime createdTime;
    private LocalDateTime updatedTime;
}