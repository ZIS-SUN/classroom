package com.seatreservation.controller;

import com.seatreservation.utils.Result;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/test")
public class TestController {

    @GetMapping("/hello")
    public Result<Map<String, Object>> hello() {
        Map<String, Object> data = new HashMap<>();
        data.put("message", "自习室座位预约系统后端API服务正常运行！");
        data.put("timestamp", System.currentTimeMillis());
        data.put("version", "1.0.0");
        return Result.success("系统运行正常", data);
    }
}