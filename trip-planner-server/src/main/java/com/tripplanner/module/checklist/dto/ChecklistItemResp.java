package com.tripplanner.module.checklist.dto;

import lombok.Data;

@Data
public class ChecklistItemResp {
    private Long id;
    private Long tripId;
    private String title;
    private String category;
    private Integer isChecked;
    private Integer sortOrder;
}
