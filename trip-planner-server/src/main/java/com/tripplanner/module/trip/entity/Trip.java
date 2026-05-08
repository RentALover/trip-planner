package com.tripplanner.module.trip.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.tripplanner.common.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("trip")
public class Trip extends BaseEntity {

    private Long userId;
    private String tripName;
    private String destination;
    private LocalDate startDate;
    private LocalDate endDate;
    private Integer numPeople;
    private String notes;
    private String status;
    private BigDecimal totalBudget;
    private String coverImageUrl;
}
