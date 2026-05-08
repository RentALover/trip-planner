package com.tripplanner.module.item.dto;

import lombok.Data;

import java.util.List;

@Data
public class ItemBatchCreateReq {
    private List<ItemCreateReq> items;
}
