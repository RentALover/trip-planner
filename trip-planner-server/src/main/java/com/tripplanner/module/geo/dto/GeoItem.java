package com.tripplanner.module.geo.dto;

import lombok.Data;

@Data
public class GeoItem {
    private Long itemId;
    private String title;
    private String itemType;
    private String location;
    private double lat;
    private double lng;
    private int dayNumber;
}
