package com.tripplanner.module.day.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.tripplanner.common.BusinessException;
import com.tripplanner.module.day.dto.DayCreateReq;
import com.tripplanner.module.day.dto.DayDetailResp;
import com.tripplanner.module.day.dto.DayResp;
import com.tripplanner.module.day.entity.TripDay;
import com.tripplanner.module.day.mapper.DayMapper;
import com.tripplanner.module.day.service.DayService;
import com.tripplanner.module.item.dto.ItemResp;
import com.tripplanner.module.item.entity.TripItem;
import com.tripplanner.module.item.mapper.ItemMapper;
import com.tripplanner.module.transport.dto.TransportResp;
import com.tripplanner.module.transport.entity.ItemTransport;
import com.tripplanner.module.transport.mapper.TransportMapper;
import com.tripplanner.module.trip.entity.Trip;
import com.tripplanner.module.trip.mapper.TripMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DayServiceImpl implements DayService {

    private final DayMapper dayMapper;
    private final TripMapper tripMapper;
    private final ItemMapper itemMapper;
    private final TransportMapper transportMapper;

    @Override
    public List<DayResp> listByTripId(Long userId, Long tripId) {
        validateTripOwnership(userId, tripId);

        List<TripDay> days = dayMapper.selectList(
                new LambdaQueryWrapper<TripDay>()
                        .eq(TripDay::getTripId, tripId)
                        .orderByAsc(TripDay::getDayNumber));

        return days.stream().map(this::toResp).collect(Collectors.toList());
    }

    @Override
    @Transactional
    public DayResp create(Long userId, Long tripId, DayCreateReq req) {
        validateTripOwnership(userId, tripId);

        int maxDayNumber = getMaxDayNumber(tripId);
        TripDay day = new TripDay();
        day.setTripId(tripId);
        day.setDayNumber(maxDayNumber + 1);
        day.setDate(req.getDate());
        day.setNotes(req.getNotes());
        day.setSortOrder(maxDayNumber);
        dayMapper.insert(day);

        return toResp(day);
    }

    @Override
    @Transactional
    public List<DayResp> generateDays(Long userId, Long tripId) {
        Trip trip = tripMapper.selectById(tripId);
        if (trip == null || !trip.getUserId().equals(userId)) {
            throw BusinessException.forbidden("无权操作此行程");
        }

        long daysBetween = ChronoUnit.DAYS.between(trip.getStartDate(), trip.getEndDate()) + 1;
        if (daysBetween > 60) {
            throw new BusinessException("行程天数不能超过60天");
        }

        // Physical delete existing items, transports and days for this trip
        List<TripDay> oldDays = dayMapper.selectList(
                new LambdaQueryWrapper<TripDay>().eq(TripDay::getTripId, tripId));
        for (TripDay oldDay : oldDays) {
            transportMapper.hardDeleteByDayId(oldDay.getId());
            itemMapper.hardDeleteByDayId(oldDay.getId());
        }
        dayMapper.hardDeleteByTripId(tripId);

        List<TripDay> days = new ArrayList<>();
        for (int i = 0; i < daysBetween; i++) {
            LocalDate date = trip.getStartDate().plusDays(i);
            TripDay day = new TripDay();
            day.setTripId(tripId);
            day.setDayNumber(i + 1);
            day.setDate(date);
            day.setSortOrder(i);
            dayMapper.insert(day);
            days.add(day);
        }

        // Auto-create transport placeholders: first item on day 1, last item on final day
        TripDay firstDay = days.get(0);
        TripDay lastDay = days.get(days.size() - 1);

        TripItem arrivalItem = new TripItem();
        arrivalItem.setDayId(firstDay.getId());
        arrivalItem.setTripId(tripId);
        arrivalItem.setItemType("TRANSPORT");
        arrivalItem.setTitle("");
        arrivalItem.setSortOrder(0.0);  // always first
        itemMapper.insert(arrivalItem);

        TripItem departureItem = new TripItem();
        departureItem.setDayId(lastDay.getId());
        departureItem.setTripId(tripId);
        departureItem.setItemType("TRANSPORT");
        departureItem.setTitle("");
        departureItem.setSortOrder(1_000_000.0);  // always last
        itemMapper.insert(departureItem);

        return days.stream().map(this::toResp).collect(Collectors.toList());
    }

    @Override
    public DayDetailResp getDetail(Long userId, Long tripId, Long dayId) {
        TripDay day = findAndValidate(userId, dayId);

        DayDetailResp resp = new DayDetailResp();
        BeanUtils.copyProperties(day, resp);

        List<TripItem> items = itemMapper.selectList(
                new LambdaQueryWrapper<TripItem>()
                        .eq(TripItem::getDayId, dayId)
                        .orderByAsc(TripItem::getSortOrder));
        resp.setItems(items.stream().map(this::toItemResp).collect(Collectors.toList()));

        List<ItemTransport> transports = transportMapper.selectList(
                new LambdaQueryWrapper<ItemTransport>()
                        .eq(ItemTransport::getDayId, dayId)
                        .orderByAsc(ItemTransport::getSortOrder));
        resp.setTransports(transports.stream().map(this::toTransportResp).collect(Collectors.toList()));

        return resp;
    }

    @Override
    @Transactional
    public DayResp update(Long userId, Long tripId, Long dayId, DayCreateReq req) {
        TripDay day = findAndValidate(userId, dayId);
        if (req.getDate() != null) day.setDate(req.getDate());
        if (req.getNotes() != null) day.setNotes(req.getNotes());
        dayMapper.updateById(day);
        return toResp(day);
    }

    @Override
    @Transactional
    public void delete(Long userId, Long tripId, Long dayId) {
        findAndValidate(userId, dayId);
        // Cascade delete items and transports for this day
        itemMapper.delete(new LambdaQueryWrapper<TripItem>().eq(TripItem::getDayId, dayId));
        transportMapper.delete(new LambdaQueryWrapper<ItemTransport>().eq(ItemTransport::getDayId, dayId));
        dayMapper.deleteById(dayId);
    }

    @Override
    public TripDay findAndValidate(Long userId, Long dayId) {
        TripDay day = dayMapper.selectById(dayId);
        if (day == null) {
            throw BusinessException.notFound("日程不存在");
        }
        validateTripOwnership(userId, day.getTripId());
        return day;
    }

    private void validateTripOwnership(Long userId, Long tripId) {
        Trip trip = tripMapper.selectById(tripId);
        if (trip == null) {
            throw BusinessException.notFound("行程不存在");
        }
        if (!trip.getUserId().equals(userId)) {
            throw BusinessException.forbidden("无权操作此行程");
        }
    }

    private int getMaxDayNumber(Long tripId) {
        List<TripDay> days = dayMapper.selectList(
                new LambdaQueryWrapper<TripDay>()
                        .eq(TripDay::getTripId, tripId)
                        .orderByDesc(TripDay::getDayNumber)
                        .last("LIMIT 1"));
        return days.isEmpty() ? 0 : days.get(0).getDayNumber();
    }

    private DayResp toResp(TripDay day) {
        DayResp resp = new DayResp();
        BeanUtils.copyProperties(day, resp);
        resp.setItemCount(itemMapper.selectCount(
                new LambdaQueryWrapper<TripItem>().eq(TripItem::getDayId, day.getId())));
        return resp;
    }

    private ItemResp toItemResp(TripItem item) {
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
