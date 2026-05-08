package com.tripplanner.module.item.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.tripplanner.common.BusinessException;
import com.tripplanner.module.day.entity.TripDay;
import com.tripplanner.module.day.mapper.DayMapper;
import com.tripplanner.module.item.dto.*;
import com.tripplanner.module.item.entity.TripItem;
import com.tripplanner.module.item.mapper.ItemMapper;
import com.tripplanner.module.item.service.ItemService;
import com.tripplanner.module.transport.dto.TransportResp;
import com.tripplanner.module.transport.entity.ItemTransport;
import com.tripplanner.module.transport.mapper.TransportMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ItemServiceImpl implements ItemService {

    private final ItemMapper itemMapper;
    private final DayMapper dayMapper;
    private final TransportMapper transportMapper;

    private static final double SORT_GAP = 1000.0;

    @Override
    public List<ItemResp> listByDayId(Long userId, Long dayId) {
        validateDayOwnership(userId, dayId);

        List<TripItem> items = itemMapper.selectList(
                new LambdaQueryWrapper<TripItem>()
                        .eq(TripItem::getDayId, dayId)
                        .orderByAsc(TripItem::getSortOrder));

        return items.stream().map(this::toResp).collect(Collectors.toList());
    }

    @Override
    @Transactional
    public ItemResp create(Long userId, Long dayId, ItemCreateReq req) {
        TripDay day = validateDayOwnership(userId, dayId);

        // Validate time overlap
        if (req.getStartTime() != null && req.getEndTime() != null) {
            checkTimeOverlap(dayId, null, req.getStartTime(), req.getEndTime());
        }

        TripItem item = new TripItem();
        BeanUtils.copyProperties(req, item);
        item.setDayId(dayId);
        item.setTripId(day.getTripId());

        // Auto-assign sort order to end of list
        if (req.getSortOrder() == null) {
            double maxSort = getMaxSortOrder(dayId);
            item.setSortOrder(maxSort + SORT_GAP);
        }

        itemMapper.insert(item);
        return toResp(item);
    }

    @Override
    public ItemResp getById(Long userId, Long dayId, Long itemId) {
        TripItem item = findAndValidate(userId, dayId, itemId);
        return toResp(item);
    }

    @Override
    @Transactional
    public ItemResp update(Long userId, Long dayId, Long itemId, ItemUpdateReq req) {
        TripItem item = findAndValidate(userId, dayId, itemId);

        // Validate time overlap (use updated values if provided, otherwise existing)
        LocalTime newStart = req.getStartTime() != null ? req.getStartTime() : item.getStartTime();
        LocalTime newEnd = req.getEndTime() != null ? req.getEndTime() : item.getEndTime();
        if (newStart != null && newEnd != null) {
            checkTimeOverlap(dayId, itemId, newStart, newEnd);
        }

        if (req.getTitle() != null) item.setTitle(req.getTitle());
        if (req.getDescription() != null) item.setDescription(req.getDescription());
        if (req.getStartTime() != null) item.setStartTime(req.getStartTime());
        if (req.getEndTime() != null) item.setEndTime(req.getEndTime());
        if (req.getLocation() != null) item.setLocation(req.getLocation());
        if (req.getCost() != null) item.setCost(req.getCost());
        if (req.getItemDetails() != null) item.setItemDetails(req.getItemDetails());

        itemMapper.updateById(item);
        return toResp(item);
    }

    @Override
    @Transactional
    public void delete(Long userId, Long dayId, Long itemId) {
        findAndValidate(userId, dayId, itemId);

        // Cascade delete associated transports
        transportMapper.delete(new LambdaQueryWrapper<ItemTransport>()
                .eq(ItemTransport::getFromItemId, itemId)
                .or().eq(ItemTransport::getToItemId, itemId));

        itemMapper.deleteById(itemId);
    }

    @Override
    @Transactional
    public ReorderResult reorder(Long userId, Long dayId, ItemSortReq req) {
        validateDayOwnership(userId, dayId);

        // 1. Update sort orders
        for (ItemSortReq.SortItem sortItem : req.getItems()) {
            TripItem item = itemMapper.selectById(sortItem.getId());
            if (item != null && item.getDayId().equals(dayId)) {
                item.setSortOrder(sortItem.getSortOrder());
                itemMapper.updateById(item);
            }
        }

        // 2. Get all items in new order
        List<TripItem> items = itemMapper.selectList(
                new LambdaQueryWrapper<TripItem>()
                        .eq(TripItem::getDayId, dayId)
                        .orderByAsc(TripItem::getSortOrder));

        // 3. Adjust transports: remove non-adjacent, update adjacent sort orders
        List<ItemTransport> transports = transportMapper.selectList(
                new LambdaQueryWrapper<ItemTransport>()
                        .eq(ItemTransport::getDayId, dayId));

        // Build adjacency map from new ordering
        for (ItemTransport transport : transports) {
            boolean stillAdjacent = false;
            for (int i = 0; i < items.size() - 1; i++) {
                if (items.get(i).getId().equals(transport.getFromItemId())
                        && items.get(i + 1).getId().equals(transport.getToItemId())) {
                    stillAdjacent = true;
                    transport.setSortOrder(items.get(i).getSortOrder() + 0.5);
                    transportMapper.updateById(transport);
                    break;
                }
            }
            if (!stillAdjacent) {
                transportMapper.deleteById(transport.getId());
            }
        }

        // 4. Return updated state
        List<ItemTransport> updatedTransports = transportMapper.selectList(
                new LambdaQueryWrapper<ItemTransport>()
                        .eq(ItemTransport::getDayId, dayId)
                        .orderByAsc(ItemTransport::getSortOrder));

        ReorderResult result = new ReorderResult();
        result.setItems(items.stream().map(this::toResp).collect(Collectors.toList()));
        result.setTransports(updatedTransports.stream().map(this::toTransportResp).collect(Collectors.toList()));
        return result;
    }

    @Override
    @Transactional
    public List<ItemResp> batchCreate(Long userId, Long dayId, List<ItemCreateReq> items) {
        TripDay day = validateDayOwnership(userId, dayId);
        double maxSort = getMaxSortOrder(dayId);

        List<TripItem> tripItems = new ArrayList<>();
        for (int i = 0; i < items.size(); i++) {
            ItemCreateReq req = items.get(i);
            TripItem item = new TripItem();
            BeanUtils.copyProperties(req, item);
            item.setDayId(dayId);
            item.setTripId(day.getTripId());
            item.setSortOrder(maxSort + (i + 1) * SORT_GAP);
            tripItems.add(item);
        }

        for (TripItem item : tripItems) {
            itemMapper.insert(item);
        }

        return tripItems.stream().map(this::toResp).collect(Collectors.toList());
    }

    @Override
    @Transactional
    public ItemResp moveToDay(Long userId, Long dayId, Long itemId, Long targetDayId, Double sortOrder) {
        TripItem item = findAndValidate(userId, dayId, itemId);
        validateDayOwnership(userId, targetDayId);

        // Remove transports associated with this item in old day
        transportMapper.delete(new LambdaQueryWrapper<ItemTransport>()
                .eq(ItemTransport::getDayId, dayId)
                .and(w -> w.eq(ItemTransport::getFromItemId, itemId)
                        .or().eq(ItemTransport::getToItemId, itemId)));

        // Move to new day
        item.setDayId(targetDayId);
        if (sortOrder == null) {
            double maxSort = getMaxSortOrder(targetDayId);
            item.setSortOrder(maxSort + SORT_GAP);
        } else {
            item.setSortOrder(sortOrder);
        }
        itemMapper.updateById(item);

        return toResp(item);
    }

    @Override
    @Transactional
    public List<ItemResp> batchUpdateTimes(Long userId, Long dayId, ItemBatchTimeUpdateReq req) {
        validateDayOwnership(userId, dayId);
        List<ItemResp> results = new ArrayList<>();
        for (ItemBatchTimeUpdateReq.TimeEntry entry : req.getItems()) {
            TripItem item = itemMapper.selectById(entry.getId());
            if (item == null || !item.getDayId().equals(dayId)) continue;
            item.setStartTime(entry.getStartTime());
            item.setEndTime(entry.getEndTime());
            itemMapper.updateById(item);
            results.add(toResp(item));
        }
        return results;
    }

    private void checkTimeOverlap(Long dayId, Long excludeItemId, LocalTime startTime, LocalTime endTime) {
        List<TripItem> items = itemMapper.selectList(
                new LambdaQueryWrapper<TripItem>()
                        .eq(TripItem::getDayId, dayId));
        for (TripItem other : items) {
            if (excludeItemId != null && other.getId().equals(excludeItemId)) continue;
            if (other.getStartTime() == null || other.getEndTime() == null) continue;
            // Overlap: A.start < B.end AND A.end > B.start
            if (startTime.isBefore(other.getEndTime()) && endTime.isAfter(other.getStartTime())) {
                throw new BusinessException("该时间段与已有行程「" + other.getTitle() + "」冲突");
            }
        }
    }

    TripItem findAndValidate(Long userId, Long dayId, Long itemId) {
        TripItem item = itemMapper.selectById(itemId);
        if (item == null) {
            throw BusinessException.notFound("行程项不存在");
        }
        if (!item.getDayId().equals(dayId)) {
            throw BusinessException.notFound("行程项不属于该日程");
        }
        validateDayOwnership(userId, dayId);
        return item;
    }

    TripDay validateDayOwnership(Long userId, Long dayId) {
        TripDay day = dayMapper.selectById(dayId);
        if (day == null) {
            throw BusinessException.notFound("日程不存在");
        }
        return day;
    }

    private double getMaxSortOrder(Long dayId) {
        List<TripItem> items = itemMapper.selectList(
                new LambdaQueryWrapper<TripItem>()
                        .eq(TripItem::getDayId, dayId)
                        .orderByDesc(TripItem::getSortOrder)
                        .last("LIMIT 1"));
        return items.isEmpty() ? 0.0 : items.get(0).getSortOrder();
    }

    private ItemResp toResp(TripItem item) {
        ItemResp resp = new ItemResp();
        BeanUtils.copyProperties(item, resp);
        return resp;
    }

    private TransportResp toTransportResp(ItemTransport transport) {
        TransportResp resp = new TransportResp();
        BeanUtils.copyProperties(transport, resp);
        return resp;
    }
}
