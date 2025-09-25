package com.seatreservation.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.seatreservation.entity.SeatType;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface SeatTypeMapper extends BaseMapper<SeatType> {
}