package com.seatreservation.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.seatreservation.entity.Announcement;

import java.util.List;

public interface AnnouncementService extends IService<Announcement> {
    
    /**
     * 获取公告列表（公开接口）
     */
    List<Announcement> getPublicAnnouncements(Integer limit);
    
    /**
     * 获取公告详情（公开接口）
     */
    Announcement getPublicAnnouncementDetail(Long id);
    
    /**
     * 增加浏览次数
     */
    void incrementViewCount(Long id);
    
    /**
     * 管理员获取公告列表
     */
    IPage<Announcement> getAdminAnnouncements(Page<Announcement> page, String status, String type);
    
    /**
     * 管理员创建公告
     */
    Announcement createAnnouncement(Announcement announcement, Long authorId, String authorName);
    
    /**
     * 管理员更新公告
     */
    Announcement updateAnnouncement(Long id, Announcement announcement);
    
    /**
     * 管理员发布公告
     */
    void publishAnnouncement(Long id);
    
    /**
     * 管理员归档公告
     */
    void archiveAnnouncement(Long id);
    
    /**
     * 管理员删除公告
     */
    void deleteAnnouncement(Long id);
}