package com.tripplanner.module.day.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.tripplanner.common.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDate;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("trip_day")
public class TripDay extends BaseEntity {

    private Long tripId;
    private Integer dayNumber;
    private LocalDate date;
    private String notes;
    private Integer sortOrder;
}
