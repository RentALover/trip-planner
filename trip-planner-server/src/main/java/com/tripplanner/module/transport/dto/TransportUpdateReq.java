package com.tripplanner.module.transport.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalTime;

@Data
public class TransportUpdateReq {
    private String transportType;
    private LocalTime departureTime;
    private Integer estimatedDuration;
    private BigDecimal cost;
    private String transportNumber;
    private String routeInfo;
    private String notes;
}
