package com.tripplanner.module.auth.service;

import com.tripplanner.module.auth.dto.LoginReq;
import com.tripplanner.module.auth.dto.LoginResp;
import com.tripplanner.module.auth.dto.RegisterReq;

public interface AuthService {
    LoginResp login(LoginReq req);
    LoginResp register(RegisterReq req);
}
