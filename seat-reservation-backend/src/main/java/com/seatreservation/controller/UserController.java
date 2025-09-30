package com.seatreservation.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.seatreservation.entity.User;
import com.seatreservation.service.UserService;
import com.seatreservation.utils.Result;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@Slf4j
@RestController
@RequestMapping("/user")
public class UserController {

    @Autowired
    private UserService userService;

    /**
     * 管理员获取所有用户列表
     */
    @GetMapping("/admin/list")
    public Result<IPage<User>> getAllUsers(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String role,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String keyword) {
        try {
            Page<User> page = new Page<>(current, size);
            IPage<User> result = userService.getUserPage(page, role, status, keyword);
            return Result.success("查询成功", result);
        } catch (Exception e) {
            log.error("获取用户列表失败: {}", e.getMessage());
            return Result.error("查询失败: " + e.getMessage());
        }
    }

    /**
     * 管理员获取用户详情
     */
    @GetMapping("/admin/{userId}")
    public Result<User> getUserDetail(@PathVariable Long userId) {
        try {
            User user = userService.getUserById(userId);
            if (user == null) {
                return Result.error("用户不存在");
            }
            // 清除密码字段
            user.setPassword(null);
            return Result.success("查询成功", user);
        } catch (Exception e) {
            log.error("获取用户详情失败: {}", e.getMessage());
            return Result.error("查询失败: " + e.getMessage());
        }
    }

    /**
     * 管理员更新用户状态
     */
    @PutMapping("/admin/{userId}/status")
    public Result<Void> updateUserStatus(
            @PathVariable Long userId,
            @RequestParam String status) {
        try {
            if (!"ACTIVE".equals(status) && !"DISABLED".equals(status)) {
                return Result.error("无效的状态值");
            }

            User user = userService.getUserById(userId);
            if (user == null) {
                return Result.error("用户不存在");
            }

            user.setStatus(status);
            boolean success = userService.updateById(user);

            if (success) {
                return Result.success("状态更新成功", null);
            } else {
                return Result.error("状态更新失败");
            }
        } catch (Exception e) {
            log.error("更新用户状态失败: {}", e.getMessage());
            return Result.error("更新失败: " + e.getMessage());
        }
    }

    /**
     * 管理员删除用户
     */
    @DeleteMapping("/admin/{userId}")
    public Result<Void> deleteUser(@PathVariable Long userId) {
        try {
            User user = userService.getUserById(userId);
            if (user == null) {
                return Result.error("用户不存在");
            }

            // 不允许删除管理员用户
            if ("ADMIN".equals(user.getRole())) {
                return Result.error("不能删除管理员用户");
            }

            boolean success = userService.removeById(userId);

            if (success) {
                return Result.success("删除成功", null);
            } else {
                return Result.error("删除失败");
            }
        } catch (Exception e) {
            log.error("删除用户失败: {}", e.getMessage());
            return Result.error("删除失败: " + e.getMessage());
        }
    }

    /**
     * 管理员创建用户
     */
    @PostMapping("/admin/create")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<User> createUser(@RequestBody User user) {
        try {
            // 检查用户名是否重复
            if (userService.lambdaQuery()
                    .eq(User::getUsername, user.getUsername())
                    .count() > 0) {
                return Result.error("用户名已存在");
            }

            // 检查学号是否重复
            if (user.getStudentId() != null && userService.lambdaQuery()
                    .eq(User::getStudentId, user.getStudentId())
                    .count() > 0) {
                return Result.error("学号已存在");
            }

            // 设置默认值
            if (user.getRole() == null) {
                user.setRole("STUDENT");
            }
            if (user.getStatus() == null) {
                user.setStatus("ACTIVE");
            }
            if (user.getPassword() == null) {
                user.setPassword("123456");
            }

            // 加密密码
            user.setPassword(com.seatreservation.utils.PasswordUtils.encode(user.getPassword()));

            boolean success = userService.save(user);
            if (success) {
                user.setPassword(null); // 不返回密码
                return Result.success("用户创建成功", user);
            } else {
                return Result.error("用户创建失败");
            }
        } catch (Exception e) {
            log.error("创建用户失败: {}", e.getMessage());
            return Result.error("创建失败: " + e.getMessage());
        }
    }

    /**
     * 管理员更新用户信息
     */
    @PutMapping("/admin/{userId}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<User> updateUser(@PathVariable Long userId, @RequestBody User user) {
        try {
            User existingUser = userService.getUserById(userId);
            if (existingUser == null) {
                return Result.error("用户不存在");
            }

            // 检查用户名是否重复（排除当前用户）
            if (user.getUsername() != null && userService.lambdaQuery()
                    .eq(User::getUsername, user.getUsername())
                    .ne(User::getId, userId)
                    .count() > 0) {
                return Result.error("用户名已存在");
            }

            // 检查学号是否重复（排除当前用户）
            if (user.getStudentId() != null && userService.lambdaQuery()
                    .eq(User::getStudentId, user.getStudentId())
                    .ne(User::getId, userId)
                    .count() > 0) {
                return Result.error("学号已存在");
            }

            user.setId(userId);
            // 不允许通过此接口修改密码
            user.setPassword(null);

            boolean success = userService.updateById(user);
            if (success) {
                User updatedUser = userService.getUserById(userId);
                updatedUser.setPassword(null); // 不返回密码
                return Result.success("用户更新成功", updatedUser);
            } else {
                return Result.error("用户更新失败");
            }
        } catch (Exception e) {
            log.error("更新用户失败: {}", e.getMessage());
            return Result.error("更新失败: " + e.getMessage());
        }
    }

    /**
     * 管理员重置用户密码
     */
    @PutMapping("/admin/{userId}/reset-password")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Void> resetPassword(@PathVariable Long userId) {
        try {
            User user = userService.getUserById(userId);
            if (user == null) {
                return Result.error("用户不存在");
            }

            // 重置为默认密码 123456，并加密
            user.setPassword(com.seatreservation.utils.PasswordUtils.encode("123456"));
            boolean success = userService.updateById(user);

            if (success) {
                return Result.success("密码重置成功，新密码为：123456", null);
            } else {
                return Result.error("密码重置失败");
            }
        } catch (Exception e) {
            log.error("重置密码失败: {}", e.getMessage());
            return Result.error("重置失败: " + e.getMessage());
        }
    }
}