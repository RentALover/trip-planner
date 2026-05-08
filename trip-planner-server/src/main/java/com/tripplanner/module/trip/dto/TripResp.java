package com.tripplanner.module.trip.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
public class TripResp {
    private Long id;
    private String tripName;
    private String destination;
    private LocalDate startDate;
    private LocalDate endDate;
    private Integer numPeople;
    private String notes;
    private String status;
    private BigDecimal totalBudget;
    private String coverImageUrl;
    private Long daysCount;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}
