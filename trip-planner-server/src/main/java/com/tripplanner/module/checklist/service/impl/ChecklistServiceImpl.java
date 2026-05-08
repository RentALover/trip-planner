package com.tripplanner.module.checklist.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.tripplanner.common.BusinessException;
import com.tripplanner.module.checklist.dto.ChecklistItemReq;
import com.tripplanner.module.checklist.dto.ChecklistItemResp;
import com.tripplanner.module.checklist.entity.ChecklistItem;
import com.tripplanner.module.checklist.mapper.ChecklistMapper;
import com.tripplanner.module.checklist.service.ChecklistService;
import com.tripplanner.module.trip.entity.Trip;
import com.tripplanner.module.trip.mapper.TripMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ChecklistServiceImpl implements ChecklistService {

    private final ChecklistMapper checklistMapper;
    private final TripMapper tripMapper;

    // Preset checklist template
    private static final String[][] PRESET_ITEMS = {
        {"身份证/护照", "DOCUMENT"},
        {"机票/火车票", "DOCUMENT"},
        {"酒店预订确认", "DOCUMENT"},
        {"旅行保险单", "DOCUMENT"},
        {"行李箱", "LUGGAGE"},
        {"背包/随身包", "LUGGAGE"},
        {"手机及充电器", "ELECTRONICS"},
        {"充电宝", "ELECTRONICS"},
        {"相机", "ELECTRONICS"},
        {"转换插头", "ELECTRONICS"},
        {"换洗衣物", "CLOTHING"},
        {"外套/雨衣", "CLOTHING"},
        {"舒适步行鞋", "CLOTHING"},
        {"牙刷/牙膏", "TOILETRY"},
        {"毛巾", "TOILETRY"},
        {"防晒霜", "TOILETRY"},
        {"常用药品", "MEDICAL"},
        {"创可贴", "MEDICAL"},
        {"晕车药", "MEDICAL"},
    };

    @Override
    public List<ChecklistItemResp> listByTripId(Long userId, Long tripId, String category) {
        validateOwnership(userId, tripId);

        LambdaQueryWrapper<ChecklistItem> wrapper = new LambdaQueryWrapper<ChecklistItem>()
                .eq(ChecklistItem::getTripId, tripId)
                .orderByAsc(ChecklistItem::getSortOrder);

        if (StringUtils.hasText(category)) {
            wrapper.eq(ChecklistItem::getCategory, category);
        }

        return checklistMapper.selectList(wrapper).stream()
                .map(this::toResp).collect(Collectors.toList());
    }

    @Override
    @Transactional
    public ChecklistItemResp create(Long userId, Long tripId, ChecklistItemReq req) {
        validateOwnership(userId, tripId);

        int maxSort = getMaxSortOrder(tripId);

        ChecklistItem item = new ChecklistItem();
        item.setTripId(tripId);
        item.setTitle(req.getTitle());
        item.setCategory(req.getCategory());
        item.setIsChecked(0);
        item.setSortOrder(maxSort + 1);
        checklistMapper.insert(item);

        return toResp(item);
    }

    @Override
    @Transactional
    public ChecklistItemResp update(Long userId, Long tripId, Long itemId, ChecklistItemReq req) {
        ChecklistItem item = findAndValidate(userId, tripId, itemId);
        item.setTitle(req.getTitle());
        item.setCategory(req.getCategory());
        checklistMapper.updateById(item);
        return toResp(item);
    }

    @Override
    @Transactional
    public void delete(Long userId, Long tripId, Long itemId) {
        findAndValidate(userId, tripId, itemId);
        checklistMapper.deleteById(itemId);
    }

    @Override
    @Transactional
    public ChecklistItemResp toggle(Long userId, Long tripId, Long itemId) {
        ChecklistItem item = findAndValidate(userId, tripId, itemId);
        item.setIsChecked(item.getIsChecked() == 1 ? 0 : 1);
        checklistMapper.updateById(item);
        return toResp(item);
    }

    @Override
    @Transactional
    public List<ChecklistItemResp> toggleAll(Long userId, Long tripId, boolean isChecked) {
        validateOwnership(userId, tripId);

        int checked = isChecked ? 1 : 0;
        checklistMapper.update(null,
                new LambdaUpdateWrapper<ChecklistItem>()
                        .eq(ChecklistItem::getTripId, tripId)
                        .set(ChecklistItem::getIsChecked, checked));

        return listByTripId(userId, tripId, null);
    }

    @Override
    @Transactional
    public List<ChecklistItemResp> loadPreset(Long userId, Long tripId) {
        validateOwnership(userId, tripId);

        // Delete existing items
        checklistMapper.delete(
                new LambdaQueryWrapper<ChecklistItem>().eq(ChecklistItem::getTripId, tripId));

        List<ChecklistItem> items = new ArrayList<>();
        for (int i = 0; i < PRESET_ITEMS.length; i++) {
            ChecklistItem item = new ChecklistItem();
            item.setTripId(tripId);
            item.setTitle(PRESET_ITEMS[i][0]);
            item.setCategory(PRESET_ITEMS[i][1]);
            item.setIsChecked(0);
            item.setSortOrder(i);
            checklistMapper.insert(item);
            items.add(item);
        }

        return items.stream().map(this::toResp).collect(Collectors.toList());
    }

    private ChecklistItem findAndValidate(Long userId, Long tripId, Long itemId) {
        ChecklistItem item = checklistMapper.selectById(itemId);
        if (item == null) {
            throw BusinessException.notFound("清单项不存在");
        }
        if (!item.getTripId().equals(tripId)) {
            throw BusinessException.notFound("清单项不属于该行程");
        }
        validateOwnership(userId, tripId);
        return item;
    }

    private void validateOwnership(Long userId, Long tripId) {
        Trip trip = tripMapper.selectById(tripId);
        if (trip == null) {
            throw BusinessException.notFound("行程不存在");
        }
        if (!trip.getUserId().equals(userId)) {
            throw BusinessException.forbidden("无权操作此行程");
        }
    }

    private int getMaxSortOrder(Long tripId) {
        List<ChecklistItem> items = checklistMapper.selectList(
                new LambdaQueryWrapper<ChecklistItem>()
                        .eq(ChecklistItem::getTripId, tripId)
                        .orderByDesc(ChecklistItem::getSortOrder)
                        .last("LIMIT 1"));
        return items.isEmpty() ? 0 : items.get(0).getSortOrder();
    }

    private ChecklistItemResp toResp(ChecklistItem item) {
        ChecklistItemResp resp = new ChecklistItemResp();
        BeanUtils.copyProperties(item, resp);
        return resp;
    }
}
