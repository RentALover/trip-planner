package com.tripplanner.module.trip.controller;

import com.tripplanner.common.PageResult;
import com.tripplanner.common.Result;
import com.tripplanner.module.trip.dto.*;
import com.tripplanner.module.trip.service.TripService;
import com.tripplanner.util.UserContextHolder;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/trips")
@RequiredArgsConstructor
public class TripController {

    private final TripService tripService;

    @PostMapping
    public Result<TripResp> create(@Valid @RequestBody TripCreateReq req) {
        return Result.success(tripService.create(UserContextHolder.getUserId(), req));
    }

    @GetMapping
    public Result<PageResult<TripResp>> list(@Valid TripQueryReq req) {
        return Result.success(tripService.list(UserContextHolder.getUserId(), req));
    }

    @GetMapping("/{id}")
    public Result<TripResp> getById(@PathVariable Long id) {
        return Result.success(tripService.getById(UserContextHolder.getUserId(), id));
    }

    @PutMapping("/{id}")
    public Result<TripResp> update(@PathVariable Long id, @RequestBody TripUpdateReq req) {
        return Result.success(tripService.update(UserContextHolder.getUserId(), id, req));
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long id) {
        tripService.delete(UserContextHolder.getUserId(), id);
        return Result.success();
    }

    @PostMapping("/{id}/copy")
    public Result<TripResp> copy(@PathVariable Long id) {
        return Result.success(tripService.copy(UserContextHolder.getUserId(), id));
    }

    @PatchMapping("/{id}/status")
    public Result<TripResp> updateStatus(@PathVariable Long id,
                                          @Valid @RequestBody TripStatusReq req) {
        return Result.success(tripService.updateStatus(UserContextHolder.getUserId(), id, req.getStatus()));
    }
}
