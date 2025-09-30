package com.seatreservation.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.seatreservation.entity.Announcement;
import com.seatreservation.mapper.AnnouncementMapper;
import com.seatreservation.service.AnnouncementService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.List;

@Slf4j
@Service
public class AnnouncementServiceImpl extends ServiceImpl<AnnouncementMapper, Announcement> implements AnnouncementService {

    @Autowired
    private AnnouncementMapper announcementMapper;

    @Override
    public List<Announcement> getPublicAnnouncements(Integer limit) {
        LambdaQueryWrapper<Announcement> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Announcement::getStatus, "PUBLISHED")
                .and(wrapper -> wrapper
                    .isNull(Announcement::getExpireTime)
                    .or(w -> w.ge(Announcement::getExpireTime, LocalDateTime.now()))
                )
                .orderByDesc(Announcement::getPriority)
                .orderByDesc(Announcement::getPublishTime);

        if (limit != null && limit > 0) {
            queryWrapper.last("LIMIT " + limit);
        }

        return announcementMapper.selectList(queryWrapper);
    }

    @Override
    public Announcement getPublicAnnouncementDetail(Long id) {
        LambdaQueryWrapper<Announcement> queryWrapper = new LambdaQueryWrapper<>();
        queryWrapper.eq(Announcement::getId, id)
                .eq(Announcement::getStatus, "PUBLISHED")
                .and(wrapper -> wrapper
                    .isNull(Announcement::getExpireTime)
                    .or(w -> w.ge(Announcement::getExpireTime, LocalDateTime.now()))
                );

        return announcementMapper.selectOne(queryWrapper);
    }

    @Override
    @Transactional
    public void incrementViewCount(Long id) {
        Announcement announcement = announcementMapper.selectById(id);
        if (announcement != null) {
            int currentViewCount = announcement.getViewCount() != null ? announcement.getViewCount() : 0;
            announcement.setViewCount(currentViewCount + 1);
            announcementMapper.updateById(announcement);
        }
    }

    @Override
    public IPage<Announcement> getAdminAnnouncements(Page<Announcement> page, String status, String type) {
        LambdaQueryWrapper<Announcement> queryWrapper = new LambdaQueryWrapper<>();

        if (StringUtils.hasText(status)) {
            queryWrapper.eq(Announcement::getStatus, status);
        }

        if (StringUtils.hasText(type)) {
            queryWrapper.eq(Announcement::getType, type);
        }

        queryWrapper.orderByDesc(Announcement::getCreatedTime);

        return announcementMapper.selectPage(page, queryWrapper);
    }

    @Override
    @Transactional
    public Announcement createAnnouncement(Announcement announcement, Long authorId, String authorName) {
        announcement.setAuthorId(authorId);
        announcement.setAuthorName(authorName);
        
        // 设置默认值
        if (announcement.getStatus() == null) {
            announcement.setStatus("DRAFT");
        }
        if (announcement.getType() == null) {
            announcement.setType("NOTICE");
        }
        if (announcement.getPriority() == null) {
            announcement.setPriority("MEDIUM"); // 默认中等优先级
        }
        if (announcement.getViewCount() == null) {
            announcement.setViewCount(0);
        }

        LocalDateTime now = LocalDateTime.now();
        announcement.setCreatedTime(now);
        announcement.setUpdatedTime(now);

        announcementMapper.insert(announcement);
        log.info("创建公告成功: id={}, title={}", announcement.getId(), announcement.getTitle());

        return announcement;
    }

    @Override
    @Transactional
    public Announcement updateAnnouncement(Long id, Announcement announcement) {
        Announcement existingAnnouncement = announcementMapper.selectById(id);
        if (existingAnnouncement == null) {
            throw new RuntimeException("公告不存在");
        }

        // 保留原有的创建信息
        announcement.setId(id);
        announcement.setAuthorId(existingAnnouncement.getAuthorId());
        announcement.setAuthorName(existingAnnouncement.getAuthorName());
        announcement.setCreatedTime(existingAnnouncement.getCreatedTime());
        announcement.setViewCount(existingAnnouncement.getViewCount());
        announcement.setUpdatedTime(LocalDateTime.now());

        announcementMapper.updateById(announcement);
        log.info("更新公告成功: id={}, title={}", id, announcement.getTitle());

        return announcement;
    }

    @Override
    @Transactional
    public void publishAnnouncement(Long id) {
        Announcement announcement = announcementMapper.selectById(id);
        if (announcement == null) {
            throw new RuntimeException("公告不存在");
        }

        if ("PUBLISHED".equals(announcement.getStatus())) {
            throw new RuntimeException("公告已发布");
        }

        announcement.setStatus("PUBLISHED");
        announcement.setPublishTime(LocalDateTime.now());
        announcement.setUpdatedTime(LocalDateTime.now());

        announcementMapper.updateById(announcement);
        log.info("发布公告成功: id={}, title={}", id, announcement.getTitle());
    }

    @Override
    @Transactional
    public void archiveAnnouncement(Long id) {
        Announcement announcement = announcementMapper.selectById(id);
        if (announcement == null) {
            throw new RuntimeException("公告不存在");
        }

        announcement.setStatus("ARCHIVED");
        announcement.setUpdatedTime(LocalDateTime.now());

        announcementMapper.updateById(announcement);
        log.info("归档公告成功: id={}, title={}", id, announcement.getTitle());
    }

    @Override
    @Transactional
    public void deleteAnnouncement(Long id) {
        Announcement announcement = announcementMapper.selectById(id);
        if (announcement == null) {
            throw new RuntimeException("公告不存在");
        }

        announcementMapper.deleteById(id);
        log.info("删除公告成功: id={}, title={}", id, announcement.getTitle());
    }
}