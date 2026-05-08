package com.tripplanner.module.day.dto;

import lombok.Data;

import java.time.LocalDate;

@Data
public class DayResp {
    private Long id;
    private Long tripId;
    private Integer dayNumber;
    private LocalDate date;
    private String notes;
    private Long itemCount;
}
