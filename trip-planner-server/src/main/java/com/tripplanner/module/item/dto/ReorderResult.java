package com.tripplanner.module.item.dto;

import com.tripplanner.module.transport.dto.TransportResp;
import lombok.Data;

import java.util.List;

@Data
public class ReorderResult {
    private List<ItemResp> items;
    private List<TransportResp> transports;
}
