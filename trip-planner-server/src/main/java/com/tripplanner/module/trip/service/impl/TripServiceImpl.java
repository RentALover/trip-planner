package com.tripplanner.module.trip.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.tripplanner.common.BusinessException;
import com.tripplanner.common.PageResult;
import com.tripplanner.common.enums.TripStatusEnum;
import com.tripplanner.module.trip.dto.*;
import com.tripplanner.module.trip.entity.Trip;
import com.tripplanner.module.trip.mapper.TripMapper;
import com.tripplanner.module.trip.service.TripService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class TripServiceImpl implements TripService {

    private final TripMapper tripMapper;

    @Override
    @Transactional
    public TripResp create(Long userId, TripCreateReq req) {
        if (req.getEndDate().isBefore(req.getStartDate())) {
            throw new BusinessException("返程日期不能早于出发日期");
        }
        Trip trip = new Trip();
        BeanUtils.copyProperties(req, trip);
        trip.setUserId(userId);
        trip.setStatus("PLANNING");
        tripMapper.insert(trip);
        return toResp(trip);
    }

    @Override
    public PageResult<TripResp> list(Long userId, TripQueryReq req) {
        LambdaQueryWrapper<Trip> wrapper = new LambdaQueryWrapper<Trip>()
                .eq(Trip::getUserId, userId);

        if (StringUtils.hasText(req.getStatus())) {
            wrapper.eq(Trip::getStatus, req.getStatus());
        }
        if (StringUtils.hasText(req.getKeyword())) {
            wrapper.and(w -> w.like(Trip::getTripName, req.getKeyword())
                    .or().like(Trip::getDestination, req.getKeyword()));
        }

        String sortColumn = "create_time";
        if ("startDate".equals(req.getSortBy())) sortColumn = "start_date";
        else if ("tripName".equals(req.getSortBy())) sortColumn = "trip_name";

        boolean isAsc = "ASC".equalsIgnoreCase(req.getSortDir());
        wrapper.orderBy(true, isAsc, Trip::getCreateTime);

        Page<Trip> page = new Page<>(req.getPage(), req.getSize());
        page = tripMapper.selectPage(page, wrapper);

        List<TripResp> records = page.getRecords().stream()
                .peek(this::refreshStatusIfNeeded)
                .map(this::toResp)
                .collect(Collectors.toList());

        return PageResult.of(page.getTotal(), req.getPage(), req.getSize(), records);
    }

    @Override
    public TripResp getById(Long userId, Long tripId) {
        Trip trip = findAndValidate(userId, tripId);
        refreshStatusIfNeeded(trip);
        return toResp(trip);
    }

    @Override
    @Transactional
    public TripResp update(Long userId, Long tripId, TripUpdateReq req) {
        Trip trip = findAndValidate(userId, tripId);
        if (req.getTripName() != null) trip.setTripName(req.getTripName());
        if (req.getDestination() != null) trip.setDestination(req.getDestination());
        if (req.getStartDate() != null) trip.setStartDate(req.getStartDate());
        if (req.getEndDate() != null) trip.setEndDate(req.getEndDate());
        if (req.getNumPeople() != null) trip.setNumPeople(req.getNumPeople());
        if (req.getNotes() != null) trip.setNotes(req.getNotes());
        if (req.getTotalBudget() != null) trip.setTotalBudget(req.getTotalBudget());

        if (trip.getEndDate().isBefore(trip.getStartDate())) {
            throw new BusinessException("返程日期不能早于出发日期");
        }

        tripMapper.updateById(trip);
        return toResp(trip);
    }

    @Override
    @Transactional
    public void delete(Long userId, Long tripId) {
        Trip trip = findAndValidate(userId, tripId);
        tripMapper.deleteById(trip.getId());
    }

    @Override
    @Transactional
    public TripResp copy(Long userId, Long tripId) {
        Trip original = findAndValidate(userId, tripId);

        Trip copy = new Trip();
        BeanUtils.copyProperties(original, copy, "id", "createTime", "updateTime", "deleted");
        copy.setUserId(userId);
        copy.setTripName(original.getTripName() + " (副本)");
        copy.setStatus("PLANNING");
        copy.setId(null);
        tripMapper.insert(copy);

        return toResp(copy);
    }

    @Override
    @Transactional
    public TripResp updateStatus(Long userId, Long tripId, String status) {
        Trip trip = findAndValidate(userId, tripId);

        TripStatusEnum newStatus = TripStatusEnum.fromValue(status);
        if (newStatus == null) {
            throw new BusinessException("无效的状态值：" + status);
        }

        TripStatusEnum current = TripStatusEnum.fromValue(trip.getStatus());
        if (current != null && !current.allowedTransitions().contains(newStatus)) {
            throw new BusinessException("不允许从「" + current.getLabel() + "」切换到「" + newStatus.getLabel() + "」");
        }

        trip.setStatus(newStatus.name());
        tripMapper.updateById(trip);
        return toResp(trip);
    }

    public Trip findAndValidate(Long userId, Long tripId) {
        Trip trip = tripMapper.selectById(tripId);
        if (trip == null) {
            throw BusinessException.notFound("行程不存在");
        }
        if (!trip.getUserId().equals(userId)) {
            throw BusinessException.forbidden("无权操作此行程");
        }
        return trip;
    }

    /**
     * Auto-update status based on dates. CANCELLED is never auto-changed.
     */
    private void refreshStatusIfNeeded(Trip trip) {
        if ("CANCELLED".equals(trip.getStatus())) return;
        LocalDate today = LocalDate.now();
        if (!today.isBefore(trip.getStartDate()) && !today.isAfter(trip.getEndDate())) {
            if (!"IN_PROGRESS".equals(trip.getStatus())) {
                trip.setStatus("IN_PROGRESS");
                tripMapper.updateById(trip);
            }
        } else if (today.isAfter(trip.getEndDate())) {
            if (!"COMPLETED".equals(trip.getStatus())) {
                trip.setStatus("COMPLETED");
                tripMapper.updateById(trip);
            }
        }
    }

    private TripResp toResp(Trip trip) {
        TripResp resp = new TripResp();
        BeanUtils.copyProperties(trip, resp);
        return resp;
    }
}
