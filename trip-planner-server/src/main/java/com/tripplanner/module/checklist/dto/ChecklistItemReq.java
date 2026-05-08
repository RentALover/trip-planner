package com.tripplanner.module.checklist.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class ChecklistItemReq {
    @NotBlank(message = "事项标题不能为空")
    private String title;

    private String category = "OTHER";
}
