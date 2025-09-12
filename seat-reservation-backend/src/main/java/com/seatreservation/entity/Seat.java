package com.seatreservation.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.io.Serializable;
import java.time.LocalDateTime;

@Data
@EqualsAndHashCode(callSuper = false)
@TableName("seat")
public class Seat implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    @TableField("seat_number")
    private String seatNumber;

    @TableField("floor_number")
    private Integer floorNumber;

    @TableField("area")
    private String area;

    @TableField("seat_type_id")
    private Integer seatTypeId;

    @TableField("position_x")
    private Integer positionX;

    @TableField("position_y")
    private Integer positionY;

    @TableField("status")
    private String status;

    @TableField("has_power")
    private Boolean hasPower;

    @TableField("has_computer")
    private Boolean hasComputer;

    @TableField("description")
    private String description;

    @TableField(value = "created_time", fill = FieldFill.INSERT)
    private LocalDateTime createdTime;

    @TableField(value = "updated_time", fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedTime;
}