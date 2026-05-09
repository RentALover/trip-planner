package com.tripplanner.module.user.controller;

import com.tripplanner.common.Result;
import com.tripplanner.module.user.service.UserService;
import com.tripplanner.util.AliOssUtil;
import com.tripplanner.util.UserContextHolder;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/upload")
@RequiredArgsConstructor
public class UploadController {

    private final AliOssUtil aliOssUtil;
    private final UserService userService;

    @PostMapping("/avatar")
    public Result<String> uploadAvatar(@RequestParam("file") MultipartFile file) throws IOException {
        Long userId = UserContextHolder.getUserId();
        String ext = getExtension(file.getOriginalFilename());
        String objectName = "avatars/" + userId + "/" + UUID.randomUUID() + ext;
        String url = aliOssUtil.upload(file.getBytes(), objectName);
        userService.uploadAvatar(userId, url);
        return Result.success(url);
    }

    private String getExtension(String filename) {
        if (filename == null || !filename.contains(".")) return "";
        return filename.substring(filename.lastIndexOf("."));
    }
}
