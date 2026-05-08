package com.tripplanner.module.auth.controller;

import com.tripplanner.common.Result;
import com.tripplanner.module.auth.dto.LoginReq;
import com.tripplanner.module.auth.dto.LoginResp;
import com.tripplanner.module.auth.dto.RegisterReq;
import com.tripplanner.module.auth.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/login")
    public Result<LoginResp> login(@Valid @RequestBody LoginReq req) {
        return Result.success(authService.login(req));
    }

    @PostMapping("/register")
    public Result<LoginResp> register(@Valid @RequestBody RegisterReq req) {
        return Result.success(authService.register(req));
    }

    @PostMapping("/logout")
    public Result<Void> logout() {
        return Result.success();
    }
}
