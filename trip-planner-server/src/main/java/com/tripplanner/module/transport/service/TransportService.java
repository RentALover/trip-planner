package com.tripplanner.module.transport.service;

import com.tripplanner.module.transport.dto.TransportCreateReq;
import com.tripplanner.module.transport.dto.TransportResp;
import com.tripplanner.module.transport.dto.TransportUpdateReq;

import java.util.List;

public interface TransportService {
    List<TransportResp> listByDayId(Long userId, Long dayId);
    TransportResp create(Long userId, Long dayId, TransportCreateReq req);
    TransportResp getById(Long userId, Long dayId, Long transportId);
    TransportResp update(Long userId, Long dayId, Long transportId, TransportUpdateReq req);
    void delete(Long userId, Long dayId, Long transportId);
    TransportResp getBetweenItems(Long userId, Long dayId, Long fromItemId, Long toItemId);
}
