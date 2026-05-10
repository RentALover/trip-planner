package com.tripplanner.module.transport.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.tripplanner.common.BusinessException;
import com.tripplanner.module.day.entity.TripDay;
import com.tripplanner.module.day.mapper.DayMapper;
import com.tripplanner.module.item.entity.TripItem;
import com.tripplanner.module.item.mapper.ItemMapper;
import com.tripplanner.module.transport.dto.TransportCreateReq;
import com.tripplanner.module.transport.dto.TransportResp;
import com.tripplanner.module.transport.dto.TransportUpdateReq;
import com.tripplanner.module.transport.entity.ItemTransport;
import com.tripplanner.module.transport.mapper.TransportMapper;
import com.tripplanner.module.transport.service.TransportService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TransportServiceImpl implements TransportService {

    private final TransportMapper transportMapper;
    private final ItemMapper itemMapper;
    private final DayMapper dayMapper;

    @Override
    public List<TransportResp> listByDayId(Long userId, Long dayId) {
        validateDayOwnership(userId, dayId);

        List<ItemTransport> transports = transportMapper.selectList(
                new LambdaQueryWrapper<ItemTransport>()
                        .eq(ItemTransport::getDayId, dayId)
                        .orderByAsc(ItemTransport::getSortOrder));

        return transports.stream().map(this::toResp).collect(Collectors.toList());
    }

    @Override
    @Transactional
    public TransportResp create(Long userId, Long dayId, TransportCreateReq req) {
        TripDay day = validateDayOwnership(userId, dayId);

        // Validate from/to items exist and belong to this day
        TripItem fromItem = itemMapper.selectById(req.getFromItemId());
        TripItem toItem = itemMapper.selectById(req.getToItemId());

        if (fromItem == null || toItem == null) {
            throw BusinessException.badRequest("行程项不存在");
        }
        if (!fromItem.getDayId().equals(dayId) || !toItem.getDayId().equals(dayId)) {
            throw BusinessException.badRequest("行程项不属于当前日程");
        }

        // Validate adjacency: from and to must be adjacent in current sort order
        List<TripItem> items = itemMapper.selectList(
                new LambdaQueryWrapper<TripItem>()
                        .eq(TripItem::getDayId, dayId)
                        .orderByAsc(TripItem::getSortOrder));

        if (!areAdjacent(items, fromItem.getId(), toItem.getId())) {
            throw BusinessException.badRequest("只能为相邻的行程项添加交通方式");
        }

        // Validate transport time fits between the two items
        validateTransportTime(req.getDepartureTime(), req.getEstimatedDuration(), fromItem, toItem);

        // Count existing transports between these items to assign correct sort order
        Long existingCount = transportMapper.selectCount(
                new LambdaQueryWrapper<ItemTransport>()
                        .eq(ItemTransport::getFromItemId, req.getFromItemId())
                        .eq(ItemTransport::getToItemId, req.getToItemId()));

        ItemTransport transport = new ItemTransport();
        BeanUtils.copyProperties(req, transport);
        transport.setDayId(dayId);
        transport.setTripId(day.getTripId());
        transport.setSortOrder(fromItem.getSortOrder() + 0.5 + existingCount);

        transportMapper.insert(transport);
        return toResp(transport);
    }

    @Override
    public TransportResp getById(Long userId, Long dayId, Long transportId) {
        ItemTransport transport = findAndValidate(userId, dayId, transportId);
        return toResp(transport);
    }

    @Override
    @Transactional
    public TransportResp update(Long userId, Long dayId, Long transportId, TransportUpdateReq req) {
        ItemTransport transport = findAndValidate(userId, dayId, transportId);

        // Validate time fit
        TripItem fromItem = itemMapper.selectById(transport.getFromItemId());
        TripItem toItem = itemMapper.selectById(transport.getToItemId());
        if (fromItem != null && toItem != null) {
            var newDep = req.getDepartureTime() != null ? req.getDepartureTime() : transport.getDepartureTime();
            var newDur = req.getEstimatedDuration() != null ? req.getEstimatedDuration() : transport.getEstimatedDuration();
            validateTransportTime(newDep, newDur, fromItem, toItem);
        }

        if (req.getTransportType() != null) transport.setTransportType(req.getTransportType());
        if (req.getDepartureTime() != null) transport.setDepartureTime(req.getDepartureTime());
        if (req.getEstimatedDuration() != null) transport.setEstimatedDuration(req.getEstimatedDuration());
        if (req.getCost() != null) transport.setCost(req.getCost());
        if (req.getTransportNumber() != null) transport.setTransportNumber(req.getTransportNumber());
        if (req.getDepartureStation() != null) transport.setDepartureStation(req.getDepartureStation());
        if (req.getArrivalStation() != null) transport.setArrivalStation(req.getArrivalStation());
        if (req.getRouteInfo() != null) transport.setRouteInfo(req.getRouteInfo());
        if (req.getNotes() != null) transport.setNotes(req.getNotes());

        transportMapper.updateById(transport);
        return toResp(transport);
    }

    @Override
    @Transactional
    public void delete(Long userId, Long dayId, Long transportId) {
        findAndValidate(userId, dayId, transportId);
        transportMapper.deleteById(transportId);
    }

    @Override
    public TransportResp getBetweenItems(Long userId, Long dayId, Long fromItemId, Long toItemId) {
        validateDayOwnership(userId, dayId);

        ItemTransport transport = transportMapper.selectOne(
                new LambdaQueryWrapper<ItemTransport>()
                        .eq(ItemTransport::getDayId, dayId)
                        .eq(ItemTransport::getFromItemId, fromItemId)
                        .eq(ItemTransport::getToItemId, toItemId));

        return transport != null ? toResp(transport) : null;
    }

    private ItemTransport findAndValidate(Long userId, Long dayId, Long transportId) {
        ItemTransport transport = transportMapper.selectById(transportId);
        if (transport == null) {
            throw BusinessException.notFound("交通方式不存在");
        }
        if (!transport.getDayId().equals(dayId)) {
            throw BusinessException.notFound("交通方式不属于该日程");
        }
        return transport;
    }

    private TripDay validateDayOwnership(Long userId, Long dayId) {
        TripDay day = dayMapper.selectById(dayId);
        if (day == null) {
            throw BusinessException.notFound("日程不存在");
        }
        return day;
    }

    /**
     * Check if two items are adjacent in the sorted list.
     */
    private boolean areAdjacent(List<TripItem> items, Long fromId, Long toId) {
        for (int i = 0; i < items.size() - 1; i++) {
            if (items.get(i).getId().equals(fromId)
                    && items.get(i + 1).getId().equals(toId)) {
                return true;
            }
        }
        return false;
    }

    private TransportResp toResp(ItemTransport transport) {
        TransportResp resp = new TransportResp();
        BeanUtils.copyProperties(transport, resp);
        return resp;
    }

    private void validateTransportTime(LocalTime departureTime, Integer durationMinutes,
                                        TripItem fromItem, TripItem toItem) {
        if (departureTime == null) return;

        // Transport must not start before the previous item ends
        if (fromItem.getEndTime() != null && departureTime.isBefore(fromItem.getEndTime())) {
            throw new BusinessException("交通出发时间不能早于上一行程结束时间 "
                    + fromItem.getEndTime());
        }

        // Transport arrival must not exceed next item start
        if (durationMinutes != null && toItem.getStartTime() != null) {
            LocalTime arrivalTime = departureTime.plusMinutes(durationMinutes);
            if (arrivalTime.isAfter(toItem.getStartTime())) {
                throw new BusinessException("交通到达时间不能晚于下一行程开始时间 "
                        + toItem.getStartTime());
            }
        }
    }
}
