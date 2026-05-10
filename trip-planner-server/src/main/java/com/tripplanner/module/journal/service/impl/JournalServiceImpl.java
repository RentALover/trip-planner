package com.tripplanner.module.journal.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.tripplanner.common.BusinessException;
import com.tripplanner.module.day.entity.TripDay;
import com.tripplanner.module.day.mapper.DayMapper;
import com.tripplanner.module.journal.dto.JournalReq;
import com.tripplanner.module.journal.dto.JournalResp;
import com.tripplanner.module.journal.entity.DayJournal;
import com.tripplanner.module.journal.mapper.JournalMapper;
import com.tripplanner.module.journal.service.JournalService;
import com.tripplanner.module.trip.entity.Trip;
import com.tripplanner.module.trip.mapper.TripMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class JournalServiceImpl implements JournalService {

    private final JournalMapper journalMapper;
    private final DayMapper dayMapper;
    private final TripMapper tripMapper;

    @Override
    public JournalResp getByDayId(Long userId, Long dayId) {
        TripDay day = validateDayOwnership(userId, dayId);
        DayJournal journal = journalMapper.selectOne(
                new LambdaQueryWrapper<DayJournal>().eq(DayJournal::getDayId, dayId));
        return journal != null ? toResp(journal) : null;
    }

    @Override
    @Transactional
    public JournalResp save(Long userId, Long dayId, JournalReq req) {
        TripDay day = validateDayOwnership(userId, dayId);

        DayJournal journal = journalMapper.selectOne(
                new LambdaQueryWrapper<DayJournal>().eq(DayJournal::getDayId, dayId));

        if (journal == null) {
            journal = new DayJournal();
            journal.setDayId(dayId);
            journal.setTripId(day.getTripId());
        }

        journal.setContent(req.getContent());
        journal.setMood(req.getMood());
        journal.setWeather(req.getWeather());
        journal.setImageUrls(req.getImageUrls());

        if (journal.getId() == null) {
            journalMapper.insert(journal);
        } else {
            journalMapper.updateById(journal);
        }

        return toResp(journal);
    }

    @Override
    @Transactional
    public void delete(Long userId, Long dayId) {
        validateDayOwnership(userId, dayId);
        journalMapper.delete(new LambdaQueryWrapper<DayJournal>().eq(DayJournal::getDayId, dayId));
    }

    private TripDay validateDayOwnership(Long userId, Long dayId) {
        TripDay day = dayMapper.selectById(dayId);
        if (day == null) {
            throw BusinessException.notFound("日程不存在");
        }
        Trip trip = tripMapper.selectById(day.getTripId());
        if (trip == null || !trip.getUserId().equals(userId)) {
            throw BusinessException.forbidden("无权操作");
        }
        return day;
    }

    private JournalResp toResp(DayJournal journal) {
        JournalResp resp = new JournalResp();
        BeanUtils.copyProperties(journal, resp);
        return resp;
    }
}
