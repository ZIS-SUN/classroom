package com.seatreservation.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.io.Serializable;
import java.time.LocalDateTime;

@Data
@EqualsAndHashCode(callSuper = false)
@TableName("sys_announcement")
public class Announcement implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    @TableField("title")
    private String title;

    @TableField("content")
    private String content;

    @TableField("type")
    private String type; // NOTICE: 通知, ANNOUNCEMENT: 公告, URGENT: 紧急

    @TableField("status")
    private String status; // DRAFT: 草稿, PUBLISHED: 已发布, ARCHIVED: 已归档

    @TableField("author_id")
    private Long authorId;

    @TableField("author_name")
    private String authorName;

    @TableField("priority")
    private String priority; // 优先级: LOW/MEDIUM/HIGH

    @TableField("publish_time")
    private LocalDateTime publishTime;

    @TableField("expire_time")
    private LocalDateTime expireTime;

    @TableField("view_count")
    private Integer viewCount;

    @TableField(value = "created_time", fill = FieldFill.INSERT)
    private LocalDateTime createdTime;

    @TableField(value = "updated_time", fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedTime;
}