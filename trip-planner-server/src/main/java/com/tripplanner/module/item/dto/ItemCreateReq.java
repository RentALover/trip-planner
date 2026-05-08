package com.tripplanner.module.item.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalTime;

@Data
public class ItemCreateReq {
    @NotBlank(message = "行程项类型不能为空")
    private String itemType;

    @NotBlank(message = "标题不能为空")
    private String title;

    private String description;
    private LocalTime startTime;
    private LocalTime endTime;
    private String location;
    private BigDecimal cost;
    private String itemDetails;
    private Double sortOrder;
}
