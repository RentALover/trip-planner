package com.tripplanner.module.journal.controller;

import com.tripplanner.common.Result;
import com.tripplanner.module.journal.dto.JournalReq;
import com.tripplanner.module.journal.dto.JournalResp;
import com.tripplanner.module.journal.service.JournalService;
import com.tripplanner.util.UserContextHolder;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/days/{dayId}/journal")
@RequiredArgsConstructor
public class JournalController {

    private final JournalService journalService;

    @GetMapping
    public Result<JournalResp> get(@PathVariable Long dayId) {
        JournalResp journal = journalService.getByDayId(UserContextHolder.getUserId(), dayId);
        return Result.success(journal);
    }

    @PutMapping
    public Result<JournalResp> save(@PathVariable Long dayId, @Valid @RequestBody JournalReq req) {
        return Result.success(journalService.save(UserContextHolder.getUserId(), dayId, req));
    }

    @DeleteMapping
    public Result<Void> delete(@PathVariable Long dayId) {
        journalService.delete(UserContextHolder.getUserId(), dayId);
        return Result.success();
    }
}
