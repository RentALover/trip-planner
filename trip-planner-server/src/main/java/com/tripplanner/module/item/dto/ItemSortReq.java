package com.tripplanner.module.item.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.List;

@Data
public class ItemSortReq {
    @NotNull(message = "排序列表不能为空")
    private List<SortItem> items;

    @Data
    public static class SortItem {
        private Long id;
        private Double sortOrder;
    }
}
