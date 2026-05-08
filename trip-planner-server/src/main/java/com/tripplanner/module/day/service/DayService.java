package com.tripplanner.module.day.service;

import com.tripplanner.module.day.dto.DayCreateReq;
import com.tripplanner.module.day.dto.DayDetailResp;
import com.tripplanner.module.day.dto.DayResp;
import com.tripplanner.module.day.entity.TripDay;

import java.util.List;

public interface DayService {
    List<DayResp> listByTripId(Long userId, Long tripId);
    DayResp create(Long userId, Long tripId, DayCreateReq req);
    List<DayResp> generateDays(Long userId, Long tripId);
    DayDetailResp getDetail(Long userId, Long tripId, Long dayId);
    DayResp update(Long userId, Long tripId, Long dayId, DayCreateReq req);
    void delete(Long userId, Long tripId, Long dayId);
    TripDay findAndValidate(Long userId, Long dayId);
}
