package com.seatreservation.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.seatreservation.entity.SeatFavorite;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface SeatFavoriteMapper extends BaseMapper<SeatFavorite> {

    /**
     * 获取用户收藏的座位列表（包含座位详情）
     */
    @Select("SELECT sf.*, s.seat_number, s.area as seat_area, s.floor_number, " +
            "st.type_name as seat_type_name, s.has_power, s.has_computer " +
            "FROM seat_favorite sf " +
            "JOIN seat s ON sf.seat_id = s.id " +
            "JOIN seat_type st ON s.seat_type_id = st.id " +
            "WHERE sf.user_id = #{userId} " +
            "ORDER BY sf.created_time DESC")
    List<SeatFavorite> selectUserFavoritesWithDetails(@Param("userId") Long userId);

    /**
     * 检查用户是否已收藏该座位
     */
    @Select("SELECT COUNT(1) FROM seat_favorite WHERE user_id = #{userId} AND seat_id = #{seatId}")
    int checkFavoriteExists(@Param("userId") Long userId, @Param("seatId") Long seatId);
}