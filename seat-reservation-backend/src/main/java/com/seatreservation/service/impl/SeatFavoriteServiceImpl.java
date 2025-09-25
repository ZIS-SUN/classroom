package com.seatreservation.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.seatreservation.entity.SeatFavorite;
import com.seatreservation.mapper.SeatFavoriteMapper;
import com.seatreservation.service.SeatFavoriteService;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class SeatFavoriteServiceImpl extends ServiceImpl<SeatFavoriteMapper, SeatFavorite> implements SeatFavoriteService {

    @Override
    public boolean addFavorite(Long userId, Long seatId, String favoriteName) {
        // 检查是否已存在
        if (isFavorited(userId, seatId)) {
            throw new RuntimeException("座位已收藏");
        }

        SeatFavorite favorite = new SeatFavorite();
        favorite.setUserId(userId);
        favorite.setSeatId(seatId);
        favorite.setFavoriteName(favoriteName);

        return save(favorite);
    }

    @Override
    public boolean removeFavorite(Long userId, Long seatId) {
        QueryWrapper<SeatFavorite> wrapper = new QueryWrapper<>();
        wrapper.eq("user_id", userId).eq("seat_id", seatId);
        return remove(wrapper);
    }

    @Override
    public List<SeatFavorite> getUserFavorites(Long userId) {
        return baseMapper.selectUserFavoritesWithDetails(userId);
    }

    @Override
    public boolean isFavorited(Long userId, Long seatId) {
        return baseMapper.checkFavoriteExists(userId, seatId) > 0;
    }

    @Override
    public boolean updateFavoriteName(Long userId, Long seatId, String favoriteName) {
        QueryWrapper<SeatFavorite> wrapper = new QueryWrapper<>();
        wrapper.eq("user_id", userId).eq("seat_id", seatId);
        
        SeatFavorite favorite = new SeatFavorite();
        favorite.setFavoriteName(favoriteName);
        
        return update(favorite, wrapper);
    }
}