package com.seatreservation.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.seatreservation.dto.SeatQueryRequest;
import com.seatreservation.entity.Seat;
import com.seatreservation.entity.SeatType;
import com.seatreservation.service.SeatService;
import com.seatreservation.utils.Result;
import com.seatreservation.vo.SeatVO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;

@Slf4j
@RestController
@RequestMapping("/seat")
public class SeatController {

    @Autowired
    private SeatService seatService;

    /**
     * 分页查询座位
     */
    @GetMapping("/page")
    public Result<IPage<SeatVO>> getSeatPage(
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            SeatQueryRequest request) {
        try {
            Page<Seat> page = new Page<>(current, size);
            IPage<SeatVO> result = seatService.getSeatPage(page, request);
            return Result.success("查询成功", result);
        } catch (Exception e) {
            log.error("分页查询座位失败: {}", e.getMessage());
            return Result.error("查询失败: " + e.getMessage());
        }
    }

    /**
     * 获取所有座位类型
     */
    @GetMapping("/types")
    public Result<List<SeatType>> getAllSeatTypes() {
        try {
            List<SeatType> seatTypes = seatService.getAllSeatTypes();
            return Result.success("查询成功", seatTypes);
        } catch (Exception e) {
            log.error("获取座位类型失败: {}", e.getMessage());
            return Result.error("查询失败: " + e.getMessage());
        }
    }

    /**
     * 查询可用座位
     */
    @GetMapping("/available")
    public Result<List<SeatVO>> getAvailableSeats(
            @RequestParam(required = false) String area,
            @RequestParam(required = false) Integer floorNumber,
            @RequestParam(required = false) Integer seatTypeId,
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate date,
            @RequestParam @DateTimeFormat(pattern = "HH:mm") LocalTime startTime,
            @RequestParam @DateTimeFormat(pattern = "HH:mm") LocalTime endTime) {
        try {
            List<SeatVO> availableSeats = seatService.getAvailableSeats(
                area, floorNumber, seatTypeId, date, startTime, endTime);
            return Result.success("查询成功", availableSeats);
        } catch (Exception e) {
            log.error("查询可用座位失败: {}", e.getMessage());
            return Result.error("查询失败: " + e.getMessage());
        }
    }

    /**
     * 获取座位详情
     */
    @GetMapping("/{id}")
    public Result<SeatVO> getSeatDetail(@PathVariable Long id) {
        try {
            SeatVO seatVO = seatService.getSeatDetail(id);
            if (seatVO == null) {
                return Result.error("座位不存在");
            }
            return Result.success("查询成功", seatVO);
        } catch (Exception e) {
            log.error("获取座位详情失败: {}", e.getMessage());
            return Result.error("查询失败: " + e.getMessage());
        }
    }

    /**
     * 获取座位布局数据（用于前端可视化）
     */
    @GetMapping("/layout")
    public Result<List<SeatVO>> getSeatLayout(
            @RequestParam(required = false) Integer floorNumber,
            @RequestParam(required = false) String area,
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") LocalDate date,
            @RequestParam(required = false) @DateTimeFormat(pattern = "HH:mm") LocalTime startTime,
            @RequestParam(required = false) @DateTimeFormat(pattern = "HH:mm") LocalTime endTime) {
        try {
            SeatQueryRequest request = new SeatQueryRequest();
            request.setFloorNumber(floorNumber);
            request.setArea(area);
            request.setDate(date);
            request.setStartTime(startTime);
            request.setEndTime(endTime);
            
            Page<Seat> page = new Page<>(1, 1000); // 获取足够多的数据用于布局显示
            IPage<SeatVO> result = seatService.getSeatPage(page, request);
            
            return Result.success("查询成功", result.getRecords());
        } catch (Exception e) {
            log.error("获取座位布局失败: {}", e.getMessage());
            return Result.error("查询失败: " + e.getMessage());
        }
    }

    // ========== 管理员接口 ==========

    /**
     * 管理员创建座位
     */
    @PostMapping("/admin/create")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Seat> createSeat(@Valid @RequestBody Seat seat) {
        try {
            // 检查座位号是否重复
            if (seatService.lambdaQuery()
                    .eq(Seat::getSeatNumber, seat.getSeatNumber())
                    .count() > 0) {
                return Result.error("座位号已存在");
            }
            
            // 设置默认状态
            if (seat.getStatus() == null) {
                seat.setStatus("AVAILABLE");
            }
            
            boolean success = seatService.save(seat);
            if (success) {
                return Result.success("座位创建成功", seat);
            } else {
                return Result.error("座位创建失败");
            }
        } catch (Exception e) {
            log.error("创建座位失败: {}", e.getMessage());
            return Result.error("创建失败: " + e.getMessage());
        }
    }

    /**
     * 管理员更新座位
     */
    @PutMapping("/admin/{seatId}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Seat> updateSeat(@PathVariable Long seatId, @Valid @RequestBody Seat seat) {
        try {
            Seat existingSeat = seatService.getById(seatId);
            if (existingSeat == null) {
                return Result.error("座位不存在");
            }

            // 检查座位号是否重复（排除当前座位）
            if (seatService.lambdaQuery()
                    .eq(Seat::getSeatNumber, seat.getSeatNumber())
                    .ne(Seat::getId, seatId)
                    .count() > 0) {
                return Result.error("座位号已存在");
            }

            seat.setId(seatId);
            boolean success = seatService.updateById(seat);
            
            if (success) {
                return Result.success("座位更新成功", seat);
            } else {
                return Result.error("座位更新失败");
            }
        } catch (Exception e) {
            log.error("更新座位失败: {}", e.getMessage());
            return Result.error("更新失败: " + e.getMessage());
        }
    }

    /**
     * 管理员删除座位
     */
    @DeleteMapping("/admin/{seatId}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Void> deleteSeat(@PathVariable Long seatId) {
        try {
            Seat seat = seatService.getById(seatId);
            if (seat == null) {
                return Result.error("座位不存在");
            }

            // 检查座位是否有未完成的预约
            boolean hasActiveReservations = seatService.hasActiveReservations(seatId);
            if (hasActiveReservations) {
                return Result.error("该座位存在未完成的预约，无法删除");
            }

            boolean success = seatService.removeById(seatId);
            
            if (success) {
                return Result.success("座位删除成功", null);
            } else {
                return Result.error("座位删除失败");
            }
        } catch (Exception e) {
            log.error("删除座位失败: {}", e.getMessage());
            return Result.error("删除失败: " + e.getMessage());
        }
    }

    /**
     * 管理员更新座位状态
     */
    @PutMapping("/admin/{seatId}/status")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Void> updateSeatStatus(@PathVariable Long seatId, @RequestParam String status) {
        try {
            // 验证状态值
            if (!"AVAILABLE".equals(status) && !"OCCUPIED".equals(status) && 
                !"MAINTENANCE".equals(status) && !"DISABLED".equals(status)) {
                return Result.error("无效的状态值");
            }

            Seat seat = seatService.getById(seatId);
            if (seat == null) {
                return Result.error("座位不存在");
            }

            seatService.updateSeatStatus(seatId, status);
            return Result.success("状态更新成功", null);
            
        } catch (Exception e) {
            log.error("更新座位状态失败: {}", e.getMessage());
            return Result.error("更新失败: " + e.getMessage());
        }
    }
}