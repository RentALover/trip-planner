package com.tripplanner.module.day.dto;

import com.tripplanner.module.item.dto.ItemResp;
import com.tripplanner.module.transport.dto.TransportResp;
import lombok.Data;

import java.time.LocalDate;
import java.util.List;

@Data
public class DayDetailResp {
    private Long id;
    private Long tripId;
    private Integer dayNumber;
    private LocalDate date;
    private String notes;
    private List<ItemResp> items;
    private List<TransportResp> transports;
}
