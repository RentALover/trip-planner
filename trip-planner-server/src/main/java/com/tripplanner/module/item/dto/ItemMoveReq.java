package com.tripplanner.module.item.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class ItemMoveReq {
    @NotNull(message = "目标日程ID不能为空")
    private Long targetDayId;

    private Double sortOrder;
}
