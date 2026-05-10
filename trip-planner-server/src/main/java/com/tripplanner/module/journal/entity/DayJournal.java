package com.tripplanner.module.journal.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.tripplanner.common.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("day_journal")
public class DayJournal extends BaseEntity {
    private Long dayId;
    private Long tripId;
    private String content;
    private String mood;
    private String weather;
    private String imageUrls;
}
