package com.tripplanner.module.item.controller;

import com.tripplanner.common.Result;
import com.tripplanner.module.item.dto.*;
import com.tripplanner.module.item.service.ItemService;
import com.tripplanner.util.UserContextHolder;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/days/{dayId}/items")
@RequiredArgsConstructor
public class ItemController {

    private final ItemService itemService;

    @GetMapping
    public Result<List<ItemResp>> list(@PathVariable Long dayId) {
        return Result.success(itemService.listByDayId(UserContextHolder.getUserId(), dayId));
    }

    @PostMapping
    public Result<ItemResp> create(@PathVariable Long dayId, @Valid @RequestBody ItemCreateReq req) {
        return Result.success(itemService.create(UserContextHolder.getUserId(), dayId, req));
    }

    @GetMapping("/{itemId}")
    public Result<ItemResp> getById(@PathVariable Long dayId, @PathVariable Long itemId) {
        return Result.success(itemService.getById(UserContextHolder.getUserId(), dayId, itemId));
    }

    @PutMapping("/{itemId}")
    public Result<ItemResp> update(@PathVariable Long dayId, @PathVariable Long itemId,
                                    @RequestBody ItemUpdateReq req) {
        return Result.success(itemService.update(UserContextHolder.getUserId(), dayId, itemId, req));
    }

    @DeleteMapping("/{itemId}")
    public Result<Void> delete(@PathVariable Long dayId, @PathVariable Long itemId) {
        itemService.delete(UserContextHolder.getUserId(), dayId, itemId);
        return Result.success();
    }

    @PutMapping("/reorder")
    public Result<ReorderResult> reorder(@PathVariable Long dayId,
                                          @Valid @RequestBody ItemSortReq req) {
        return Result.success(itemService.reorder(UserContextHolder.getUserId(), dayId, req));
    }

    @PostMapping("/batch")
    public Result<List<ItemResp>> batchCreate(@PathVariable Long dayId,
                                              @RequestBody ItemBatchCreateReq req) {
        return Result.success(itemService.batchCreate(UserContextHolder.getUserId(), dayId, req.getItems()));
    }

    @PatchMapping("/{itemId}/move")
    public Result<ItemResp> moveToDay(@PathVariable Long dayId, @PathVariable Long itemId,
                                       @Valid @RequestBody ItemMoveReq req) {
        return Result.success(itemService.moveToDay(UserContextHolder.getUserId(), dayId,
                itemId, req.getTargetDayId(), req.getSortOrder()));
    }
}
