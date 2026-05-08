package com.tripplanner.module.budget.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.tripplanner.common.BusinessException;
import com.tripplanner.module.budget.dto.BudgetByCategoryResp;
import com.tripplanner.module.budget.dto.BudgetByDayResp;
import com.tripplanner.module.budget.dto.BudgetSummaryResp;
import com.tripplanner.module.budget.service.BudgetService;
import com.tripplanner.module.day.entity.TripDay;
import com.tripplanner.module.day.mapper.DayMapper;
import com.tripplanner.module.item.entity.TripItem;
import com.tripplanner.module.item.mapper.ItemMapper;
import com.tripplanner.module.transport.entity.ItemTransport;
import com.tripplanner.module.transport.mapper.TransportMapper;
import com.tripplanner.module.trip.entity.Trip;
import com.tripplanner.module.trip.mapper.TripMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class BudgetServiceImpl implements BudgetService {

    private final TripMapper tripMapper;
    private final DayMapper dayMapper;
    private final ItemMapper itemMapper;
    private final TransportMapper transportMapper;

    @Override
    public BudgetSummaryResp getSummary(Long userId, Long tripId) {
        Trip trip = validateOwnership(userId, tripId);

        List<TripItem> items = itemMapper.selectList(
                new LambdaQueryWrapper<TripItem>().eq(TripItem::getTripId, tripId));
        List<ItemTransport> transports = transportMapper.selectList(
                new LambdaQueryWrapper<ItemTransport>().eq(ItemTransport::getTripId, tripId));

        BudgetSummaryResp resp = new BudgetSummaryResp();
        resp.setTotalBudget(trip.getTotalBudget());

        BigDecimal itemTotal = items.stream()
                .map(i -> i.getCost() != null ? i.getCost() : BigDecimal.ZERO)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        BigDecimal transportTotal = transports.stream()
                .map(t -> t.getCost() != null ? t.getCost() : BigDecimal.ZERO)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        resp.setItemTotal(itemTotal);
        resp.setTransportTotal(transportTotal);

        // Category breakdown
        Map<String, BigDecimal> byType = items.stream()
                .collect(Collectors.groupingBy(
                        TripItem::getItemType,
                        Collectors.reducing(BigDecimal.ZERO,
                                i -> i.getCost() != null ? i.getCost() : BigDecimal.ZERO,
                                BigDecimal::add)));

        resp.setAccommodationTotal(byType.getOrDefault("ACCOMMODATION", BigDecimal.ZERO));
        resp.setDiningTotal(byType.getOrDefault("DINING", BigDecimal.ZERO));
        resp.setAttractionTotal(byType.getOrDefault("ATTRACTION", BigDecimal.ZERO));
        resp.setShoppingTotal(byType.getOrDefault("SHOPPING", BigDecimal.ZERO));
        resp.setOtherTotal(byType.getOrDefault("OTHER", BigDecimal.ZERO));

        resp.setSpentTotal(itemTotal.add(transportTotal));
        if (trip.getTotalBudget() != null) {
            resp.setRemainingBudget(trip.getTotalBudget().subtract(resp.getSpentTotal()));
        } else {
            resp.setRemainingBudget(BigDecimal.ZERO.subtract(resp.getSpentTotal()));
        }

        return resp;
    }

    @Override
    public List<BudgetByDayResp> getByDay(Long userId, Long tripId) {
        validateOwnership(userId, tripId);

        List<TripDay> days = dayMapper.selectList(
                new LambdaQueryWrapper<TripDay>()
                        .eq(TripDay::getTripId, tripId)
                        .orderByAsc(TripDay::getDayNumber));

        List<BudgetByDayResp> result = new ArrayList<>();
        for (TripDay day : days) {
            List<TripItem> items = itemMapper.selectList(
                    new LambdaQueryWrapper<TripItem>().eq(TripItem::getDayId, day.getId()));
            List<ItemTransport> transports = transportMapper.selectList(
                    new LambdaQueryWrapper<ItemTransport>().eq(ItemTransport::getDayId, day.getId()));

            BigDecimal itemCost = items.stream()
                    .map(i -> i.getCost() != null ? i.getCost() : BigDecimal.ZERO)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);
            BigDecimal transportCost = transports.stream()
                    .map(t -> t.getCost() != null ? t.getCost() : BigDecimal.ZERO)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);

            BudgetByDayResp dayResp = new BudgetByDayResp();
            dayResp.setDayId(day.getId());
            dayResp.setDayNumber(day.getDayNumber());
            dayResp.setDate(day.getDate());
            dayResp.setItemCost(itemCost);
            dayResp.setTransportCost(transportCost);
            dayResp.setDayTotal(itemCost.add(transportCost));
            result.add(dayResp);
        }

        return result;
    }

    @Override
    public List<BudgetByCategoryResp> getByCategory(Long userId, Long tripId) {
        validateOwnership(userId, tripId);

        List<TripItem> items = itemMapper.selectList(
                new LambdaQueryWrapper<TripItem>().eq(TripItem::getTripId, tripId));
        List<ItemTransport> transports = transportMapper.selectList(
                new LambdaQueryWrapper<ItemTransport>().eq(ItemTransport::getTripId, tripId));

        BigDecimal totalCost = items.stream()
                .map(i -> i.getCost() != null ? i.getCost() : BigDecimal.ZERO)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        BigDecimal transportCost = transports.stream()
                .map(t -> t.getCost() != null ? t.getCost() : BigDecimal.ZERO)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        BigDecimal grandTotal = totalCost.add(transportCost);

        Map<String, List<TripItem>> grouped = items.stream()
                .collect(Collectors.groupingBy(TripItem::getItemType));

        List<BudgetByCategoryResp> result = new ArrayList<>();
        String[] categories = {"TRANSPORT", "ACCOMMODATION", "DINING", "ATTRACTION", "SHOPPING", "OTHER"};
        String[] labels = {"交通", "住宿", "餐饮", "景点", "购物", "其他"};

        for (int i = 0; i < categories.length; i++) {
            List<TripItem> catItems = grouped.getOrDefault(categories[i], List.of());
            BigDecimal catTotal = catItems.stream()
                    .map(it -> it.getCost() != null ? it.getCost() : BigDecimal.ZERO)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);

            // Add transport cost to TRANSPORT category
            if ("TRANSPORT".equals(categories[i])) {
                catTotal = catTotal.add(transportCost);
            }

            BudgetByCategoryResp catResp = new BudgetByCategoryResp();
            catResp.setCategory(labels[i]);
            catResp.setCount((long) catItems.size());
            catResp.setTotalCost(catTotal);

            if (grandTotal.compareTo(BigDecimal.ZERO) > 0) {
                catResp.setPercentage(catTotal.multiply(BigDecimal.valueOf(100))
                        .divide(grandTotal, 1, RoundingMode.HALF_UP));
            } else {
                catResp.setPercentage(BigDecimal.ZERO);
            }
            result.add(catResp);
        }

        return result;
    }

    private Trip validateOwnership(Long userId, Long tripId) {
        Trip trip = tripMapper.selectById(tripId);
        if (trip == null) {
            throw BusinessException.notFound("行程不存在");
        }
        if (!trip.getUserId().equals(userId)) {
            throw BusinessException.forbidden("无权操作此行程");
        }
        return trip;
    }
}
