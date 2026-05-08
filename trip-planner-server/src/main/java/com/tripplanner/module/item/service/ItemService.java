package com.tripplanner.module.item.service;

import com.tripplanner.module.item.dto.*;

import java.util.List;

public interface ItemService {
    List<ItemResp> listByDayId(Long userId, Long dayId);
    ItemResp create(Long userId, Long dayId, ItemCreateReq req);
    ItemResp getById(Long userId, Long dayId, Long itemId);
    ItemResp update(Long userId, Long dayId, Long itemId, ItemUpdateReq req);
    void delete(Long userId, Long dayId, Long itemId);
    ReorderResult reorder(Long userId, Long dayId, ItemSortReq req);
    List<ItemResp> batchCreate(Long userId, Long dayId, List<ItemCreateReq> items);
    ItemResp moveToDay(Long userId, Long dayId, Long itemId, Long targetDayId, Double sortOrder);
    List<ItemResp> batchUpdateTimes(Long userId, Long dayId, ItemBatchTimeUpdateReq req);
}
