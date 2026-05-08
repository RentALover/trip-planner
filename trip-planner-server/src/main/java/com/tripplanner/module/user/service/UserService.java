package com.tripplanner.module.user.service;

import com.tripplanner.module.user.dto.PasswordChangeReq;
import com.tripplanner.module.user.dto.UserProfileResp;
import com.tripplanner.module.user.dto.UserUpdateReq;
import com.tripplanner.module.user.entity.User;

public interface UserService {
    UserProfileResp getProfile(Long userId);
    UserProfileResp updateProfile(Long userId, UserUpdateReq req);
    void changePassword(Long userId, PasswordChangeReq req);
    User findById(Long userId);
    String uploadAvatar(Long userId, String avatarUrl);
}
