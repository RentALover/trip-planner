package com.tripplanner.module.photo.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.tripplanner.common.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("trip_photo")
public class TripPhoto extends BaseEntity {
    private Long tripId;
    private String url;
    private String location;
    private String photoType;
    private Boolean isFeatured;
    private Integer sortOrder;
}
