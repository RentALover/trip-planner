package com.tripplanner.module.trip.dto;

import lombok.Data;

@Data
public class TripQueryReq {
    private Integer page = 1;
    private Integer size = 10;
    private String status;
    private String keyword;
    private String sortBy = "createTime";
    private String sortDir = "DESC";
}
