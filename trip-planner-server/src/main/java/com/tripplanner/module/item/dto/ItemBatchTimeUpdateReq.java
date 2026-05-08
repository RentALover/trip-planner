package com.tripplanner.module.item.dto;

import lombok.Data;

import java.time.LocalTime;
import java.util.List;

@Data
public class ItemBatchTimeUpdateReq {
    private List<TimeEntry> items;

    @Data
    public static class TimeEntry {
        private Long id;
        private LocalTime startTime;
        private LocalTime endTime;
    }
}
