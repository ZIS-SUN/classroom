package com.seatreservation.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.io.Serializable;
import java.time.LocalDateTime;

@Data
@EqualsAndHashCode(callSuper = false)
@TableName("feedback")
public class Feedback implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    @TableField("user_id")
    private Long userId;

    @TableField("type")
    private String type; // SUGGESTION-建议, BUG-问题, COMPLAINT-投诉, OTHER-其他

    @TableField("content")
    private String content;

    @TableField("reply")
    private String reply;

    @TableField("status")
    private String status; // PENDING-待处理, REPLIED-已回复, CLOSED-已关闭

    @TableField("created_time")
    private LocalDateTime createdTime;

    @TableField("updated_time")
    private LocalDateTime updatedTime;

    @TableField("replied_time")
    private LocalDateTime repliedTime;

    @TableField("replied_by")
    private Long repliedBy;

    // 关联字段（不存储到数据库）
    @TableField(exist = false)
    private String username;

    @TableField(exist = false)
    private String realName;

    @TableField(exist = false)
    private String repliedByName;
}