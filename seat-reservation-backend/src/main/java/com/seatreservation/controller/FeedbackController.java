package com.seatreservation.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.seatreservation.service.FeedbackService;
import com.seatreservation.utils.JwtUtils;
import com.seatreservation.utils.Result;
import com.seatreservation.entity.Feedback;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/feedback")
public class FeedbackController {

    @Autowired
    private FeedbackService feedbackService;

    @Autowired
    private JwtUtils jwtUtils;

    /**
     * 提交反馈
     */
    @PostMapping("/submit")
    public Result<String> submitFeedback(@RequestBody Map<String, String> request, 
                                       HttpServletRequest httpRequest) {
        try {
            Long userId = jwtUtils.getUserIdFromRequest(httpRequest);
            String type = request.get("type");
            String content = request.get("content");
            
            if (type == null || content == null || content.trim().isEmpty()) {
                return Result.error("反馈类型和内容不能为空");
            }
            
            feedbackService.submitFeedback(userId, type, content.trim());
            return Result.success("反馈提交成功，我们会尽快处理");
            
        } catch (Exception e) {
            log.error("提交反馈失败: {}", e.getMessage(), e);
            return Result.error("提交失败: " + e.getMessage());
        }
    }

    /**
     * 获取我的反馈列表
     */
    @GetMapping("/my")
    public Result<IPage<Feedback>> getMyFeedback(@RequestParam(defaultValue = "1") int current,
                                               @RequestParam(defaultValue = "10") int size,
                                               HttpServletRequest request) {
        try {
            Long userId = jwtUtils.getUserIdFromRequest(request);
            IPage<Feedback> page = feedbackService.getUserFeedbackPage(userId, current, size);
            return Result.success("查询成功", page);
            
        } catch (Exception e) {
            log.error("查询反馈失败: {}", e.getMessage(), e);
            return Result.error("查询失败: " + e.getMessage());
        }
    }

    /**
     * 获取反馈列表（管理员）
     */
    @GetMapping("/list")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<IPage<Feedback>> getFeedbackList(@RequestParam(defaultValue = "1") int current,
                                                  @RequestParam(defaultValue = "10") int size,
                                                  @RequestParam(required = false) String type,
                                                  @RequestParam(required = false) String status) {
        try {
            IPage<Feedback> page = feedbackService.getFeedbackPage(current, size, type, status);
            return Result.success("查询成功", page);
            
        } catch (Exception e) {
            log.error("查询反馈列表失败: {}", e.getMessage(), e);
            return Result.error("查询失败: " + e.getMessage());
        }
    }

    /**
     * 回复反馈（管理员）
     */
    @PostMapping("/{id}/reply")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<String> replyFeedback(@PathVariable Long id,
                                      @RequestBody Map<String, String> request,
                                      HttpServletRequest httpRequest) {
        try {
            Long adminId = jwtUtils.getUserIdFromRequest(httpRequest);
            String reply = request.get("reply");
            
            if (reply == null || reply.trim().isEmpty()) {
                return Result.error("回复内容不能为空");
            }
            
            feedbackService.replyFeedback(id, reply.trim(), adminId);
            return Result.success("回复成功");
            
        } catch (Exception e) {
            log.error("回复反馈失败: {}", e.getMessage(), e);
            return Result.error("回复失败: " + e.getMessage());
        }
    }

    /**
     * 关闭反馈（管理员）
     */
    @PostMapping("/{id}/close")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<String> closeFeedback(@PathVariable Long id) {
        try {
            feedbackService.closeFeedback(id);
            return Result.success("反馈已关闭");
            
        } catch (Exception e) {
            log.error("关闭反馈失败: {}", e.getMessage(), e);
            return Result.error("操作失败: " + e.getMessage());
        }
    }

    /**
     * 获取反馈详情
     */
    @GetMapping("/{id}")
    public Result<Feedback> getFeedbackDetail(@PathVariable Long id,
                                            HttpServletRequest request) {
        try {
            Long userId = jwtUtils.getUserIdFromRequest(request);
            Feedback feedback = feedbackService.getById(id);
            
            if (feedback == null) {
                return Result.error("反馈不存在");
            }
            
            // 检查权限：只有反馈提交者或管理员可以查看
            String userRole = jwtUtils.getRoleFromRequest(request);
            if (!feedback.getUserId().equals(userId) && !"ADMIN".equals(userRole)) {
                return Result.error("没有权限查看此反馈");
            }
            
            return Result.success("查询成功", feedback);
            
        } catch (Exception e) {
            log.error("查询反馈详情失败: {}", e.getMessage(), e);
            return Result.error("查询失败: " + e.getMessage());
        }
    }
}