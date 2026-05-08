package com.tripplanner.module.transport.controller;

import com.tripplanner.common.Result;
import com.tripplanner.module.transport.dto.TransportCreateReq;
import com.tripplanner.module.transport.dto.TransportResp;
import com.tripplanner.module.transport.dto.TransportUpdateReq;
import com.tripplanner.module.transport.service.TransportService;
import com.tripplanner.util.UserContextHolder;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/days/{dayId}/transports")
@RequiredArgsConstructor
public class TransportController {

    private final TransportService transportService;

    @GetMapping
    public Result<List<TransportResp>> list(@PathVariable Long dayId) {
        return Result.success(transportService.listByDayId(UserContextHolder.getUserId(), dayId));
    }

    @PostMapping
    public Result<TransportResp> create(@PathVariable Long dayId,
                                         @Valid @RequestBody TransportCreateReq req) {
        return Result.success(transportService.create(UserContextHolder.getUserId(), dayId, req));
    }

    @GetMapping("/{id}")
    public Result<TransportResp> getById(@PathVariable Long dayId, @PathVariable("id") Long transportId) {
        return Result.success(transportService.getById(UserContextHolder.getUserId(), dayId, transportId));
    }

    @PutMapping("/{id}")
    public Result<TransportResp> update(@PathVariable Long dayId, @PathVariable("id") Long transportId,
                                         @RequestBody TransportUpdateReq req) {
        return Result.success(transportService.update(UserContextHolder.getUserId(), dayId, transportId, req));
    }

    @DeleteMapping("/{id}")
    public Result<Void> delete(@PathVariable Long dayId, @PathVariable("id") Long transportId) {
        transportService.delete(UserContextHolder.getUserId(), dayId, transportId);
        return Result.success();
    }

    @GetMapping("/between")
    public Result<TransportResp> getBetween(@PathVariable Long dayId,
                                             @RequestParam Long fromItemId,
                                             @RequestParam Long toItemId) {
        return Result.success(transportService.getBetweenItems(
                UserContextHolder.getUserId(), dayId, fromItemId, toItemId));
    }
}
