package com.seatreservation.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.seatreservation.entity.PaymentRecord;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface PaymentRecordMapper extends BaseMapper<PaymentRecord> {
}