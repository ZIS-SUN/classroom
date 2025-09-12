package com.seatreservation.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.seatreservation.entity.Announcement;
import com.seatreservation.service.AnnouncementService;
import com.seatreservation.utils.JwtUtils;
import com.seatreservation.utils.Result;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import javax.validation.Valid;
import java.util.List;

@Slf4j
@RestController
@RequestMapping("/announcement")
public class AnnouncementController {

    @Autowired
    private AnnouncementService announcementService;

    @Autowired
    private JwtUtils jwtUtils;

    // ========== 公开接口 ==========

    /**
     * 获取公开公告列表
     */
    @GetMapping("/public/list")
    public Result<List<Announcement>> getPublicAnnouncements(
            @RequestParam(defaultValue = "10") Integer limit) {
        try {
            List<Announcement> announcements = announcementService.getPublicAnnouncements(limit);
            return Result.success("查询成功", announcements);
        } catch (Exception e) {
            log.error("获取公告列表失败: {}", e.getMessage());
            return Result.error("查询失败: " + e.getMessage());
        }
    }

    /**
     * 获取公开公告详情
     */
    @GetMapping("/public/{id}")
    public Result<Announcement> getPublicAnnouncementDetail(@PathVariable Long id) {
        try {
            Announcement announcement = announcementService.getPublicAnnouncementDetail(id);
            if (announcement == null) {
                return Result.error("公告不存在或已过期");
            }
            
            // 增加浏览次数
            announcementService.incrementViewCount(id);
            
            return Result.success("查询成功", announcement);
        } catch (Exception e) {
            log.error("获取公告详情失败: {}", e.getMessage());
            return Result.error("查询失败: " + e.getMessage());
        }
    }

    // ========== 管理员接口 ==========

    /**
     * 管理员获取公告列表
     */
    @GetMapping("/admin/list")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<IPage<Announcement>> getAdminAnnouncements(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String type) {
        try {
            Page<Announcement> page = new Page<>(current, size);
            IPage<Announcement> result = announcementService.getAdminAnnouncements(page, status, type);
            return Result.success("查询成功", result);
        } catch (Exception e) {
            log.error("管理员获取公告列表失败: {}", e.getMessage());
            return Result.error("查询失败: " + e.getMessage());
        }
    }

    /**
     * 管理员获取公告详情
     */
    @GetMapping("/admin/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Announcement> getAdminAnnouncementDetail(@PathVariable Long id) {
        try {
            Announcement announcement = announcementService.getById(id);
            if (announcement == null) {
                return Result.error("公告不存在");
            }
            return Result.success("查询成功", announcement);
        } catch (Exception e) {
            log.error("管理员获取公告详情失败: {}", e.getMessage());
            return Result.error("查询失败: " + e.getMessage());
        }
    }

    /**
     * 管理员创建公告
     */
    @PostMapping("/admin/create")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Announcement> createAnnouncement(
            @Valid @RequestBody Announcement announcement,
            HttpServletRequest httpRequest) {
        try {
            Long authorId = getCurrentUserId(httpRequest);
            String authorName = getUsernameFromRequest(httpRequest);
            
            Announcement result = announcementService.createAnnouncement(announcement, authorId, authorName);
            return Result.success("公告创建成功", result);
        } catch (Exception e) {
            log.error("创建公告失败: {}", e.getMessage());
            return Result.error("创建失败: " + e.getMessage());
        }
    }

    /**
     * 管理员更新公告
     */
    @PutMapping("/admin/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Announcement> updateAnnouncement(
            @PathVariable Long id,
            @Valid @RequestBody Announcement announcement) {
        try {
            Announcement result = announcementService.updateAnnouncement(id, announcement);
            return Result.success("公告更新成功", result);
        } catch (Exception e) {
            log.error("更新公告失败: {}", e.getMessage());
            return Result.error("更新失败: " + e.getMessage());
        }
    }

    /**
     * 管理员发布公告
     */
    @PostMapping("/admin/{id}/publish")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Void> publishAnnouncement(@PathVariable Long id) {
        try {
            announcementService.publishAnnouncement(id);
            return Result.success("公告发布成功", null);
        } catch (Exception e) {
            log.error("发布公告失败: {}", e.getMessage());
            return Result.error("发布失败: " + e.getMessage());
        }
    }

    /**
     * 管理员归档公告
     */
    @PostMapping("/admin/{id}/archive")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Void> archiveAnnouncement(@PathVariable Long id) {
        try {
            announcementService.archiveAnnouncement(id);
            return Result.success("公告归档成功", null);
        } catch (Exception e) {
            log.error("归档公告失败: {}", e.getMessage());
            return Result.error("归档失败: " + e.getMessage());
        }
    }

    /**
     * 管理员删除公告
     */
    @DeleteMapping("/admin/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Void> deleteAnnouncement(@PathVariable Long id) {
        try {
            announcementService.deleteAnnouncement(id);
            return Result.success("公告删除成功", null);
        } catch (Exception e) {
            log.error("删除公告失败: {}", e.getMessage());
            return Result.error("删除失败: " + e.getMessage());
        }
    }

    // ========== 辅助方法 ==========

    /**
     * 从HTTP请求中获取当前用户ID
     */
    private Long getCurrentUserId(HttpServletRequest request) {
        String token = getTokenFromRequest(request);
        if (token == null) {
            throw new RuntimeException("未找到认证token");
        }
        
        if (!jwtUtils.validateToken(token)) {
            throw new RuntimeException("无效的token");
        }
        
        return jwtUtils.getUserIdFromToken(token);
    }

    /**
     * 从HTTP请求中获取用户名
     */
    private String getUsernameFromRequest(HttpServletRequest request) {
        String token = getTokenFromRequest(request);
        if (token == null) {
            throw new RuntimeException("未找到认证token");
        }
        
        if (!jwtUtils.validateToken(token)) {
            throw new RuntimeException("无效的token");
        }
        
        return jwtUtils.getUsernameFromToken(token);
    }

    /**
     * 从HTTP请求中提取token
     */
    private String getTokenFromRequest(HttpServletRequest request) {
        String authHeader = request.getHeader("Authorization");
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            return authHeader.substring(7);
        }
        return null;
    }
}