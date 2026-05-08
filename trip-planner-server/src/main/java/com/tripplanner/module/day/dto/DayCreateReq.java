package com.tripplanner.module.day.dto;

import lombok.Data;

import java.time.LocalDate;

@Data
public class DayCreateReq {
    private LocalDate date;
    private String notes;
}
