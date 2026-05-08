package com.tripplanner.module.checklist.controller;

import com.tripplanner.common.Result;
import com.tripplanner.module.checklist.dto.ChecklistItemReq;
import com.tripplanner.module.checklist.dto.ChecklistItemResp;
import com.tripplanner.module.checklist.dto.ToggleAllReq;
import com.tripplanner.module.checklist.service.ChecklistService;
import com.tripplanner.util.UserContextHolder;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/trips/{tripId}/checklist")
@RequiredArgsConstructor
public class ChecklistController {

    private final ChecklistService checklistService;

    @GetMapping
    public Result<List<ChecklistItemResp>> list(@PathVariable Long tripId,
                                                 @RequestParam(required = false) String category) {
        return Result.success(checklistService.listByTripId(UserContextHolder.getUserId(), tripId, category));
    }

    @PostMapping
    public Result<ChecklistItemResp> create(@PathVariable Long tripId,
                                             @Valid @RequestBody ChecklistItemReq req) {
        return Result.success(checklistService.create(UserContextHolder.getUserId(), tripId, req));
    }

    @PutMapping("/{id}")
    public Result<ChecklistItemResp> update(@PathVariable Long tripId, @PathVariable Long id,
                                             @Valid @RequestBody ChecklistItemReq req) {
        return Result.success(checklistService.update(UserContextHolder.getUserId(), tripId, id, req));
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long tripId, @PathVariable Long id) {
        checklistService.delete(UserContextHolder.getUserId(), tripId, id);
        return Result.success();
    }

    @PatchMapping("/{id}/toggle")
    public Result<ChecklistItemResp> toggle(@PathVariable Long tripId, @PathVariable Long id) {
        return Result.success(checklistService.toggle(UserContextHolder.getUserId(), tripId, id));
    }

    @PatchMapping("/toggle-all")
    public Result<List<ChecklistItemResp>> toggleAll(@PathVariable Long tripId,
                                                      @RequestBody ToggleAllReq req) {
        return Result.success(checklistService.toggleAll(UserContextHolder.getUserId(), tripId,
                req.getIsChecked() != null && req.getIsChecked()));
    }

    @PostMapping("/preset")
    public Result<List<ChecklistItemResp>> loadPreset(@PathVariable Long tripId) {
        return Result.success(checklistService.loadPreset(UserContextHolder.getUserId(), tripId));
    }
}
