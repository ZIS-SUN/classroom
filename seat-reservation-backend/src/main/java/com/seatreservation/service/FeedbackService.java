package com.seatreservation.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.IService;
import com.seatreservation.entity.Feedback;

public interface FeedbackService extends IService<Feedback> {
    
    /**
     * 提交反馈
     */
    void submitFeedback(Long userId, String type, String content);
    
    /**
     * 分页查询反馈列表（管理员）
     */
    IPage<Feedback> getFeedbackPage(int current, int size, String type, String status);
    
    /**
     * 查询用户的反馈列表
     */
    IPage<Feedback> getUserFeedbackPage(Long userId, int current, int size);
    
    /**
     * 回复反馈
     */
    void replyFeedback(Long feedbackId, String reply, Long repliedBy);
    
    /**
     * 关闭反馈
     */
    void closeFeedback(Long feedbackId);
}