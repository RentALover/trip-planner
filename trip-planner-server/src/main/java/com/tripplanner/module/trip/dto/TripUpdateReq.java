package com.tripplanner.module.trip.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
public class TripUpdateReq {
    private String tripName;
    private String destination;
    private LocalDate startDate;
    private LocalDate endDate;
    private Integer numPeople;
    private String notes;
    private BigDecimal totalBudget;
}
