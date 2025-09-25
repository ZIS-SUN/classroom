package com.seatreservation.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.io.Serializable;
import java.time.LocalDateTime;

@Data
@EqualsAndHashCode(callSuper = false)
@TableName("seat_favorite")
public class SeatFavorite implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    @TableField("user_id")
    private Long userId;

    @TableField("seat_id")
    private Long seatId;

    @TableField("favorite_name")
    private String favoriteName;

    @TableField(value = "created_time", fill = FieldFill.INSERT)
    private LocalDateTime createdTime;

    @TableField(value = "updated_time", fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedTime;

    // 非数据库字段，用于返回座位详细信息
    @TableField(exist = false)
    private String seatNumber;

    @TableField(exist = false)
    private String seatArea;

    @TableField(exist = false)
    private Integer floorNumber;

    @TableField(exist = false)
    private String seatTypeName;

    @TableField(exist = false)
    private Boolean hasPower;

    @TableField(exist = false)
    private Boolean hasComputer;
}