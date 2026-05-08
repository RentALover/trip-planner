package com.tripplanner.module.auth.service.impl;

import com.tripplanner.common.BusinessException;
import com.tripplanner.module.auth.dto.LoginReq;
import com.tripplanner.module.auth.dto.LoginResp;
import com.tripplanner.module.auth.dto.RegisterReq;
import com.tripplanner.module.auth.service.AuthService;
import com.tripplanner.module.user.entity.User;
import com.tripplanner.module.user.service.impl.UserServiceImpl;
import com.tripplanner.util.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final UserServiceImpl userServiceImpl;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;

    @Override
    public LoginResp login(LoginReq req) {
        User user = userServiceImpl.findByUsername(req.getUsername());
        if (user == null) {
            throw new BusinessException("用户名或密码错误");
        }
        if (!passwordEncoder.matches(req.getPassword(), user.getPassword())) {
            throw new BusinessException("用户名或密码错误");
        }

        String token = jwtUtil.generateToken(user.getId(), user.getUsername());
        return new LoginResp(token,
                new LoginResp.UserInfo(user.getId(), user.getUsername(),
                        user.getNickname(), user.getAvatarUrl()));
    }

    @Override
    public LoginResp register(RegisterReq req) {
        if (userServiceImpl.existsByUsername(req.getUsername())) {
            throw new BusinessException("用户名已存在");
        }

        String encodedPassword = passwordEncoder.encode(req.getPassword());
        User user = userServiceImpl.createUser(req.getUsername(), encodedPassword,
                req.getNickname(), req.getEmail());

        String token = jwtUtil.generateToken(user.getId(), user.getUsername());
        return new LoginResp(token,
                new LoginResp.UserInfo(user.getId(), user.getUsername(),
                        user.getNickname(), user.getAvatarUrl()));
    }
}
