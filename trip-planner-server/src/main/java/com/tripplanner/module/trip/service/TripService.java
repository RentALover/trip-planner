package com.tripplanner.module.trip.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.tripplanner.common.PageResult;
import com.tripplanner.module.trip.dto.*;

public interface TripService {
    TripResp create(Long userId, TripCreateReq req);
    PageResult<TripResp> list(Long userId, TripQueryReq req);
    TripResp getById(Long userId, Long tripId);
    TripResp update(Long userId, Long tripId, TripUpdateReq req);
    void delete(Long userId, Long tripId);
    TripResp copy(Long userId, Long tripId);
    TripResp updateStatus(Long userId, Long tripId, String status);
}
