package com.seatreservation.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.seatreservation.entity.UserWallet;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Update;

import java.math.BigDecimal;

@Mapper
public interface UserWalletMapper extends BaseMapper<UserWallet> {

    /**
     * 扣减钱包余额
     */
    @Update("UPDATE user_wallet SET balance = balance - #{amount}, total_consume = total_consume + #{amount}, updated_time = NOW() WHERE user_id = #{userId} AND balance >= #{amount}")
    int deductBalance(@Param("userId") Long userId, @Param("amount") BigDecimal amount);

    /**
     * 增加钱包余额
     */
    @Update("UPDATE user_wallet SET balance = balance + #{amount}, total_recharge = total_recharge + #{rechargeAmount}, updated_time = NOW() WHERE user_id = #{userId}")
    int addBalance(@Param("userId") Long userId, @Param("amount") BigDecimal amount, @Param("rechargeAmount") BigDecimal rechargeAmount);

    /**
     * 退款到钱包
     */
    @Update("UPDATE user_wallet SET balance = balance + #{amount}, total_consume = total_consume - #{amount}, updated_time = NOW() WHERE user_id = #{userId}")
    int refundToWallet(@Param("userId") Long userId, @Param("amount") BigDecimal amount);
}