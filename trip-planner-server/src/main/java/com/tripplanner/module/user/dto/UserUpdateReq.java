package com.tripplanner.module.user.dto;

import jakarta.validation.constraints.Email;
import lombok.Data;

@Data
public class UserUpdateReq {
    private String nickname;

    @Email(message = "邮箱格式不正确")
    private String email;

    private String phone;
    private String avatarUrl;
    private String bio;
}
