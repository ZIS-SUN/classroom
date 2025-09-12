package com.seatreservation;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("com.seatreservation.mapper")
public class SeatReservationApplication {

    public static void main(String[] args) {
        SpringApplication.run(SeatReservationApplication.class, args);
        System.out.println("=================================");
        System.out.println("自习室座位预约系统启动成功！");
        System.out.println("接口文档地址: http://localhost:8080/doc.html");
        System.out.println("=================================");
    }
}