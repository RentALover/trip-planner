package com.tripplanner.module.user.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.tripplanner.common.BusinessException;
import com.tripplanner.module.user.dto.PasswordChangeReq;
import com.tripplanner.module.user.dto.UserProfileResp;
import com.tripplanner.module.user.dto.UserUpdateReq;
import com.tripplanner.module.user.entity.User;
import com.tripplanner.module.user.mapper.UserMapper;
import com.tripplanner.module.user.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UserServiceImpl implements UserService {

    private final UserMapper userMapper;
    private final BCryptPasswordEncoder passwordEncoder;

    @Override
    public UserProfileResp getProfile(Long userId) {
        User user = findById(userId);
        UserProfileResp resp = new UserProfileResp();
        BeanUtils.copyProperties(user, resp);
        return resp;
    }

    @Override
    public UserProfileResp updateProfile(Long userId, UserUpdateReq req) {
        User user = findById(userId);
        if (req.getNickname() != null) {
            user.setNickname(req.getNickname());
        }
        if (req.getEmail() != null) {
            user.setEmail(req.getEmail());
        }
        if (req.getPhone() != null) {
            user.setPhone(req.getPhone());
        }
        if (req.getAvatarUrl() != null) {
            user.setAvatarUrl(req.getAvatarUrl());
        }
        if (req.getBio() != null) {
            user.setBio(req.getBio());
        }
        userMapper.updateById(user);

        UserProfileResp resp = new UserProfileResp();
        BeanUtils.copyProperties(user, resp);
        return resp;
    }

    @Override
    public void changePassword(Long userId, PasswordChangeReq req) {
        User user = findById(userId);
        if (!passwordEncoder.matches(req.getOldPassword(), user.getPassword())) {
            throw new BusinessException("原密码不正确");
        }
        user.setPassword(passwordEncoder.encode(req.getNewPassword()));
        userMapper.updateById(user);
    }

    @Override
    public User findById(Long userId) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw BusinessException.notFound("用户不存在");
        }
        return user;
    }

    @Override
    public String uploadAvatar(Long userId, String avatarUrl) {
        User user = findById(userId);
        user.setAvatarUrl(avatarUrl);
        userMapper.updateById(user);
        return avatarUrl;
    }

    public boolean existsByUsername(String username) {
        return userMapper.selectCount(
                new LambdaQueryWrapper<User>().eq(User::getUsername, username)) > 0;
    }

    public User findByUsername(String username) {
        return userMapper.selectOne(
                new LambdaQueryWrapper<User>().eq(User::getUsername, username));
    }

    public User createUser(String username, String encodedPassword, String nickname, String email) {
        User user = new User();
        user.setUsername(username);
        user.setPassword(encodedPassword);
        user.setNickname(nickname != null ? nickname : username);
        user.setEmail(email);
        userMapper.insert(user);
        return user;
    }
}
