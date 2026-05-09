package com.tripplanner.module.transport.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalTime;

@Data
public class TransportResp {
    private Long id;
    private Long dayId;
    private Long tripId;
    private Long fromItemId;
    private Long toItemId;
    private String transportType;
    private LocalTime departureTime;
    private Integer estimatedDuration;
    private BigDecimal cost;
    private String transportNumber;
    private String routeInfo;
    private String notes;
    private Double sortOrder;
}
