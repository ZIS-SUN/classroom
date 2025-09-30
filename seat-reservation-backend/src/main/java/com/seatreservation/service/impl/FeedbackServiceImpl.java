package com.seatreservation.service.impl;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.seatreservation.entity.Feedback;
import com.seatreservation.mapper.FeedbackMapper;
import com.seatreservation.service.FeedbackService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Slf4j
@Service
public class FeedbackServiceImpl extends ServiceImpl<FeedbackMapper, Feedback> implements FeedbackService {

    @Override
    public void submitFeedback(Long userId, String type, String content) {
        Feedback feedback = new Feedback();
        feedback.setUserId(userId);
        feedback.setType(type);
        feedback.setContent(content);
        feedback.setStatus("PENDING");
        feedback.setCreatedTime(LocalDateTime.now());
        feedback.setUpdatedTime(LocalDateTime.now());
        
        save(feedback);
        log.info("用户 {} 提交了反馈: {}", userId, type);
    }

    @Override
    public IPage<Feedback> getFeedbackPage(int current, int size, String type, String status) {
        Page<Feedback> page = new Page<>(current, size);
        return baseMapper.selectFeedbackPage(page, type, status);
    }

    @Override
    public IPage<Feedback> getUserFeedbackPage(Long userId, int current, int size) {
        Page<Feedback> page = new Page<>(current, size);
        return baseMapper.selectByUserId(page, userId);
    }

    @Override
    public void replyFeedback(Long feedbackId, String reply, Long repliedBy) {
        Feedback feedback = getById(feedbackId);
        if (feedback == null) {
            throw new RuntimeException("反馈不存在");
        }
        
        feedback.setReply(reply);
        feedback.setStatus("REPLIED");
        feedback.setRepliedBy(repliedBy);
        feedback.setRepliedTime(LocalDateTime.now());
        feedback.setUpdatedTime(LocalDateTime.now());
        
        updateById(feedback);
        log.info("管理员 {} 回复了反馈 {}", repliedBy, feedbackId);
    }

    @Override
    public void closeFeedback(Long feedbackId) {
        Feedback feedback = getById(feedbackId);
        if (feedback == null) {
            throw new RuntimeException("反馈不存在");
        }
        
        feedback.setStatus("CLOSED");
        feedback.setUpdatedTime(LocalDateTime.now());
        
        updateById(feedback);
        log.info("反馈 {} 已关闭", feedbackId);
    }
}