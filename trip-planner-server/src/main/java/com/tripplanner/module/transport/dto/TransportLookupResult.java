package com.tripplanner.module.transport.dto;

import lombok.Data;

@Data
public class TransportLookupResult {
    private String departureStation;
    private String arrivalStation;
    private String departureTime;
    private String arrivalTime;
    private Integer durationMinutes;
    private String routeInfo;
}
