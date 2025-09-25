package com.seatreservation.controller;

import com.seatreservation.utils.Result;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletResponse;
import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Slf4j
@RestController
@RequestMapping("/upload")
public class FileUploadController {

    @Value("${file.upload-dir:/uploads}")
    private String uploadDir;

    @Value("${server.port:8081}")
    private String serverPort;

    /**
     * 上传头像
     */
    @PostMapping("/avatar")
    public Result<Map<String, String>> uploadAvatar(@RequestParam("file") MultipartFile file) {
        return uploadFile(file, "avatars");
    }

    /**
     * 上传自习室图片
     */
    @PostMapping("/room")
    public Result<Map<String, String>> uploadRoomImage(@RequestParam("file") MultipartFile file) {
        return uploadFile(file, "rooms");
    }

    /**
     * 通用文件上传
     */
    private Result<Map<String, String>> uploadFile(MultipartFile file, String category) {
        if (file.isEmpty()) {
            return Result.error("上传文件不能为空");
        }

        try {
            // 检查文件类型
            String contentType = file.getContentType();
            if (!isImageFile(contentType)) {
                return Result.error("只支持图片文件 (jpg, jpeg, png, gif)");
            }

            // 检查文件大小 (5MB)
            if (file.getSize() > 5 * 1024 * 1024) {
                return Result.error("文件大小不能超过5MB");
            }

            // 创建上传目录
            String dateDir = new SimpleDateFormat("yyyy/MM/dd").format(new Date());
            String fullUploadDir = uploadDir + "/" + category + "/" + dateDir;
            Path uploadPath = Paths.get(fullUploadDir);
            Files.createDirectories(uploadPath);

            // 生成唯一文件名
            String originalFilename = file.getOriginalFilename();
            String fileExtension = getFileExtension(originalFilename);
            String newFileName = UUID.randomUUID().toString() + fileExtension;

            // 保存文件
            Path filePath = uploadPath.resolve(newFileName);
            Files.copy(file.getInputStream(), filePath);

            // 生成访问URL
            String fileUrl = "/api/upload/file/" + category + "/" + dateDir + "/" + newFileName;
            String fullUrl = "http://localhost:" + serverPort + fileUrl;

            Map<String, String> result = new HashMap<>();
            result.put("url", fileUrl);
            result.put("fullUrl", fullUrl);
            result.put("filename", newFileName);

            log.info("文件上传成功: {}", fullUrl);
            return Result.success("上传成功", result);

        } catch (Exception e) {
            log.error("文件上传失败: {}", e.getMessage(), e);
            return Result.error("上传失败: " + e.getMessage());
        }
    }

    /**
     * 获取文件
     */
    @GetMapping("/file/**")
    public void getFile(HttpServletResponse response, @RequestParam(required = false) String download) throws IOException {
        String requestURI = ((javax.servlet.http.HttpServletRequest) 
            org.springframework.web.context.request.RequestContextHolder
            .currentRequestAttributes()
            .resolveReference(org.springframework.web.context.request.RequestAttributes.REFERENCE_REQUEST))
            .getRequestURI();
        
        // 提取文件路径
        String filePath = requestURI.replace("/api/upload/file/", "");
        Path fullPath = Paths.get(uploadDir, filePath);

        if (!Files.exists(fullPath)) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        File file = fullPath.toFile();
        String contentType = Files.probeContentType(fullPath);
        if (contentType == null) {
            contentType = "application/octet-stream";
        }

        response.setContentType(contentType);
        response.setContentLengthLong(file.length());

        // 如果是下载请求
        if ("true".equals(download)) {
            response.setHeader("Content-Disposition", 
                "attachment; filename=\"" + file.getName() + "\"");
        }

        try (FileInputStream fis = new FileInputStream(file);
             OutputStream os = response.getOutputStream()) {
            
            byte[] buffer = new byte[8192];
            int bytesRead;
            while ((bytesRead = fis.read(buffer)) != -1) {
                os.write(buffer, 0, bytesRead);
            }
            os.flush();
        }
    }

    /**
     * 删除文件
     */
    @DeleteMapping("/file")
    public Result<String> deleteFile(@RequestParam("url") String fileUrl) {
        try {
            // 从URL提取文件路径
            String filePath = fileUrl.replace("/api/upload/file/", "");
            Path fullPath = Paths.get(uploadDir, filePath);

            if (Files.exists(fullPath)) {
                Files.delete(fullPath);
                log.info("文件删除成功: {}", fileUrl);
                return Result.success("删除成功");
            } else {
                return Result.error("文件不存在");
            }
        } catch (Exception e) {
            log.error("文件删除失败: {}", e.getMessage(), e);
            return Result.error("删除失败: " + e.getMessage());
        }
    }

    /**
     * 检查是否为图片文件
     */
    private boolean isImageFile(String contentType) {
        return contentType != null && (
            contentType.equals(MediaType.IMAGE_JPEG_VALUE) ||
            contentType.equals(MediaType.IMAGE_PNG_VALUE) ||
            contentType.equals(MediaType.IMAGE_GIF_VALUE) ||
            contentType.equals("image/jpg")
        );
    }

    /**
     * 获取文件扩展名
     */
    private String getFileExtension(String filename) {
        if (filename == null || filename.lastIndexOf('.') == -1) {
            return "";
        }
        return filename.substring(filename.lastIndexOf('.'));
    }
}