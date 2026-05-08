package com.tripplanner.module.day.controller;

import com.tripplanner.common.Result;
import com.tripplanner.module.day.dto.DayCreateReq;
import com.tripplanner.module.day.dto.DayDetailResp;
import com.tripplanner.module.day.dto.DayResp;
import com.tripplanner.module.day.service.DayService;
import com.tripplanner.util.UserContextHolder;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/trips/{tripId}/days")
@RequiredArgsConstructor
public class DayController {

    private final DayService dayService;

    @GetMapping
    public Result<List<DayResp>> list(@PathVariable Long tripId) {
        return Result.success(dayService.listByTripId(UserContextHolder.getUserId(), tripId));
    }

    @PostMapping
    public Result<DayResp> create(@PathVariable Long tripId, @RequestBody DayCreateReq req) {
        return Result.success(dayService.create(UserContextHolder.getUserId(), tripId, req));
    }

    @PostMapping("/generate")
    public Result<List<DayResp>> generate(@PathVariable Long tripId) {
        return Result.success(dayService.generateDays(UserContextHolder.getUserId(), tripId));
    }

    @GetMapping("/{dayId}")
    public Result<DayDetailResp> getDetail(@PathVariable Long tripId, @PathVariable Long dayId) {
        return Result.success(dayService.getDetail(UserContextHolder.getUserId(), tripId, dayId));
    }

    @PutMapping("/{dayId}")
    public Result<DayResp> update(@PathVariable Long tripId, @PathVariable Long dayId,
                                   @RequestBody DayCreateReq req) {
        return Result.success(dayService.update(UserContextHolder.getUserId(), tripId, dayId, req));
    }

    @DeleteMapping("/{dayId}")
    public Result<Void> delete(@PathVariable Long tripId, @PathVariable Long dayId) {
        dayService.delete(UserContextHolder.getUserId(), tripId, dayId);
        return Result.success();
    }
}
