package com.tripplanner.module.item.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalTime;

@Data
public class ItemResp {
    private Long id;
    private Long dayId;
    private Long tripId;
    private String itemType;
    private String title;
    private String description;
    private LocalTime startTime;
    private LocalTime endTime;
    private String location;
    private BigDecimal cost;
    private String itemDetails;
    private Double sortOrder;
    private String imageUrl;
}
