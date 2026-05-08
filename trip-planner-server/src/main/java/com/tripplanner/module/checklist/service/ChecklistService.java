package com.tripplanner.module.checklist.service;

import com.tripplanner.module.checklist.dto.ChecklistItemReq;
import com.tripplanner.module.checklist.dto.ChecklistItemResp;

import java.util.List;

public interface ChecklistService {
    List<ChecklistItemResp> listByTripId(Long userId, Long tripId, String category);
    ChecklistItemResp create(Long userId, Long tripId, ChecklistItemReq req);
    ChecklistItemResp update(Long userId, Long tripId, Long itemId, ChecklistItemReq req);
    void delete(Long userId, Long tripId, Long itemId);
    ChecklistItemResp toggle(Long userId, Long tripId, Long itemId);
    List<ChecklistItemResp> toggleAll(Long userId, Long tripId, boolean isChecked);
    List<ChecklistItemResp> loadPreset(Long userId, Long tripId);
}
