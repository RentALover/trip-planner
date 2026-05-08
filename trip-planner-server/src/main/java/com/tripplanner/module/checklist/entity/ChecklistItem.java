package com.tripplanner.module.checklist.entity;

import com.baomidou.mybatisplus.annotation.TableName;
import com.tripplanner.common.BaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("checklist")
public class ChecklistItem extends BaseEntity {

    private Long tripId;
    private String title;
    private String category;
    private Integer isChecked;
    private Integer sortOrder;
}
