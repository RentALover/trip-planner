package com.tripplanner.module.transport.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.tripplanner.common.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.time.LocalTime;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("item_transport")
public class ItemTransport extends BaseEntity {

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
