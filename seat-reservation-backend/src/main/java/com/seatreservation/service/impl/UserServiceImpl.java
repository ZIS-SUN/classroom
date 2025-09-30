package com.seatreservation.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.seatreservation.dto.LoginRequest;
import com.seatreservation.dto.LoginResponse;
import com.seatreservation.dto.RegisterRequest;
import com.seatreservation.entity.User;
import com.seatreservation.mapper.UserMapper;
import com.seatreservation.service.UserService;
import com.seatreservation.utils.JwtUtils;
import com.seatreservation.utils.PasswordUtils;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements UserService {

    @Autowired
    private JwtUtils jwtUtils;

    @Override
    public LoginResponse login(LoginRequest loginRequest) {
        User user = getUserByUsername(loginRequest.getUsername());

        if (user == null) {
            throw new RuntimeException("用户不存在");
        }

        if (!"ACTIVE".equals(user.getStatus())) {
            throw new RuntimeException("账号已被禁用");
        }

        // 使用BCrypt验证密码
        if (!PasswordUtils.matches(loginRequest.getPassword(), user.getPassword())) {
            throw new RuntimeException("密码错误");
        }

        String token = jwtUtils.generateToken(user.getId(), user.getUsername(), user.getRole());

        return new LoginResponse(
                token,
                user.getId(),
                user.getUsername(),
                user.getRealName(),
                user.getRole(),
                user.getEmail(),
                user.getPhone());
    }

    @Override
    @Transactional
    public void register(RegisterRequest registerRequest) {
        if (getUserByUsername(registerRequest.getUsername()) != null) {
            throw new RuntimeException("用户名已存在");
        }

        if (registerRequest.getPhone() != null) {
            QueryWrapper<User> phoneQuery = new QueryWrapper<>();
            phoneQuery.eq("phone", registerRequest.getPhone());
            if (getOne(phoneQuery) != null) {
                throw new RuntimeException("手机号已被注册");
            }
        }

        if (registerRequest.getEmail() != null) {
            QueryWrapper<User> emailQuery = new QueryWrapper<>();
            emailQuery.eq("email", registerRequest.getEmail());
            if (getOne(emailQuery) != null) {
                throw new RuntimeException("邮箱已被注册");
            }
        }

        if (registerRequest.getStudentId() != null) {
            QueryWrapper<User> studentIdQuery = new QueryWrapper<>();
            studentIdQuery.eq("student_id", registerRequest.getStudentId());
            if (getOne(studentIdQuery) != null) {
                throw new RuntimeException("学号已被注册");
            }
        }

        User user = new User();
        user.setUsername(registerRequest.getUsername());
        user.setPassword(PasswordUtils.encode(registerRequest.getPassword()));
        user.setRealName(registerRequest.getRealName());
        user.setPhone(registerRequest.getPhone());
        user.setEmail(registerRequest.getEmail());
        user.setStudentId(registerRequest.getStudentId());
        user.setRole("STUDENT");
        user.setStatus("ACTIVE");

        if (!save(user)) {
            throw new RuntimeException("注册失败");
        }

        log.info("用户注册成功: {}", registerRequest.getUsername());
    }

    @Override
    public User getUserById(Long userId) {
        return getById(userId);
    }

    @Override
    public User getUserByUsername(String username) {
        QueryWrapper<User> queryWrapper = new QueryWrapper<>();
        queryWrapper.eq("username", username);
        return getOne(queryWrapper);
    }

    @Override
    public IPage<User> getUserPage(Page<User> page, String role, String status, String keyword) {
        QueryWrapper<User> queryWrapper = new QueryWrapper<>();

        if (role != null && !role.trim().isEmpty()) {
            queryWrapper.eq("role", role);
        }

        if (status != null && !status.trim().isEmpty()) {
            queryWrapper.eq("status", status);
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            queryWrapper.and(wrapper -> wrapper
                    .like("username", keyword)
                    .or()
                    .like("real_name", keyword)
                    .or()
                    .like("phone", keyword)
                    .or()
                    .like("email", keyword)
                    .or()
                    .like("student_id", keyword));
        }

        queryWrapper.orderByDesc("created_time");

        IPage<User> result = page(page, queryWrapper);

        // 清除密码字段
        result.getRecords().forEach(user -> user.setPassword(null));

        return result;
    }
}