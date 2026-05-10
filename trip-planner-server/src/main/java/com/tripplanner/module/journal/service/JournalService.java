package com.tripplanner.module.journal.service;

import com.tripplanner.module.journal.dto.JournalReq;
import com.tripplanner.module.journal.dto.JournalResp;

public interface JournalService {
    JournalResp getByDayId(Long userId, Long dayId);
    JournalResp save(Long userId, Long dayId, JournalReq req);
    void delete(Long userId, Long dayId);
}
