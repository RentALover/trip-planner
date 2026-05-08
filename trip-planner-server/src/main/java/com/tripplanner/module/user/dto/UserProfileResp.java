package com.tripplanner.module.user.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class UserProfileResp {
    private Long id;
    private String username;
    private String nickname;
    private String email;
    private String phone;
    private String avatarUrl;
    private String bio;
    private LocalDateTime createTime;
}
