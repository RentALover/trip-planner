package com.tripplanner.module.user.controller;

import com.tripplanner.common.Result;
import com.tripplanner.module.user.dto.PasswordChangeReq;
import com.tripplanner.module.user.dto.UserProfileResp;
import com.tripplanner.module.user.dto.UserUpdateReq;
import com.tripplanner.module.user.service.UserService;
import com.tripplanner.util.UserContextHolder;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/user")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping("/profile")
    public Result<UserProfileResp> getProfile() {
        Long userId = UserContextHolder.getUserId();
        return Result.success(userService.getProfile(userId));
    }

    @PutMapping("/profile")
    public Result<UserProfileResp> updateProfile(@Valid @RequestBody UserUpdateReq req) {
        Long userId = UserContextHolder.getUserId();
        return Result.success(userService.updateProfile(userId, req));
    }

    @PutMapping("/password")
    public Result<Void> changePassword(@Valid @RequestBody PasswordChangeReq req) {
        Long userId = UserContextHolder.getUserId();
        userService.changePassword(userId, req);
        return Result.success();
    }

    @PostMapping("/avatar")
    public Result<String> uploadAvatar(@RequestBody String avatarUrl) {
        Long userId = UserContextHolder.getUserId();
        return Result.success(userService.uploadAvatar(userId, avatarUrl));
    }
}
