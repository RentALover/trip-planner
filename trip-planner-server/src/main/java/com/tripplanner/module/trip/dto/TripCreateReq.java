package com.tripplanner.module.trip.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
public class TripCreateReq {
    @NotBlank(message = "行程名称不能为空")
    private String tripName;

    @NotBlank(message = "目的地不能为空")
    private String destination;

    @NotNull(message = "出发日期不能为空")
    private LocalDate startDate;

    @NotNull(message = "返程日期不能为空")
    private LocalDate endDate;

    private Integer numPeople = 1;
    private String notes;
    private BigDecimal totalBudget;
}
