package com.tripplanner.module.item.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.tripplanner.common.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.time.LocalTime;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("trip_item")
public class TripItem extends BaseEntity {

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
