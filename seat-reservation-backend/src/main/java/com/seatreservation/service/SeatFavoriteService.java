package com.seatreservation.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.seatreservation.entity.SeatFavorite;

import java.util.List;

public interface SeatFavoriteService extends IService<SeatFavorite> {

    /**
     * 添加座位收藏
     */
    boolean addFavorite(Long userId, Long seatId, String favoriteName);

    /**
     * 取消座位收藏
     */
    boolean removeFavorite(Long userId, Long seatId);

    /**
     * 获取用户收藏列表
     */
    List<SeatFavorite> getUserFavorites(Long userId);

    /**
     * 检查是否已收藏
     */
    boolean isFavorited(Long userId, Long seatId);

    /**
     * 更新收藏备注
     */
    boolean updateFavoriteName(Long userId, Long seatId, String favoriteName);
}