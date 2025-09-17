package com.seatreservation.controller;

import com.seatreservation.entity.SeatFavorite;
import com.seatreservation.service.SeatFavoriteService;
import com.seatreservation.utils.JwtUtils;
import com.seatreservation.utils.Result;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/seat-favorite")
@CrossOrigin
public class SeatFavoriteController {

    @Autowired
    private SeatFavoriteService seatFavoriteService;

    @Autowired
    private JwtUtils jwtUtils;

    /**
     * 获取收藏列表
     */
    @GetMapping("/list")
    public Result getFavoriteList(HttpServletRequest request) {
        try {
            // 从token获取用户ID
            Long userId = jwtUtils.getUserIdFromRequest(request);

            List<SeatFavorite> favorites = seatFavoriteService.getUserFavorites(userId);
            return Result.success(favorites);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("获取收藏列表失败: " + e.getMessage());
        }
    }

    /**
     * 添加收藏
     */
    @PostMapping("/add")
    public Result addFavorite(@RequestBody Map<String, Object> params, HttpServletRequest request) {
        try {
            Long userId = jwtUtils.getUserIdFromRequest(request);

            Long seatId = Long.valueOf(params.get("seatId").toString());
            String favoriteName = (String) params.get("favoriteName");

            boolean success = seatFavoriteService.addFavorite(userId, seatId, favoriteName);
            if (success) {
                return Result.success("收藏成功");
            } else {
                return Result.error("收藏失败，可能已经收藏过了");
            }
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("收藏失败: " + e.getMessage());
        }
    }

    /**
     * 取消收藏
     */
    @DeleteMapping("/remove/{seatId}")
    public Result removeFavorite(@PathVariable Long seatId, HttpServletRequest request) {
        try {
            Long userId = jwtUtils.getUserIdFromRequest(request);

            boolean success = seatFavoriteService.removeFavorite(userId, seatId);
            if (success) {
                return Result.success("取消收藏成功");
            } else {
                return Result.error("取消收藏失败");
            }
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("取消收藏失败: " + e.getMessage());
        }
    }

    /**
     * 检查是否已收藏
     */
    @GetMapping("/check/{seatId}")
    public Result checkFavorite(@PathVariable Long seatId, HttpServletRequest request) {
        try {
            Long userId = jwtUtils.getUserIdFromRequest(request);

            boolean isFavorited = seatFavoriteService.isFavorited(userId, seatId);
            return Result.success(isFavorited);
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("检查收藏状态失败: " + e.getMessage());
        }
    }

    /**
     * 更新收藏备注
     */
    @PutMapping("/update")
    public Result updateFavoriteName(@RequestBody Map<String, Object> params, HttpServletRequest request) {
        try {
            Long userId = jwtUtils.getUserIdFromRequest(request);

            Long seatId = Long.valueOf(params.get("seatId").toString());
            String favoriteName = (String) params.get("favoriteName");

            boolean success = seatFavoriteService.updateFavoriteName(userId, seatId, favoriteName);
            if (success) {
                return Result.success("更新成功");
            } else {
                return Result.error("更新失败");
            }
        } catch (Exception e) {
            e.printStackTrace();
            return Result.error("更新失败: " + e.getMessage());
        }
    }
}