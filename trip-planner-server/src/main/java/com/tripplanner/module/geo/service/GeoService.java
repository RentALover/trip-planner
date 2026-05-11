package com.tripplanner.module.geo.service;

import com.tripplanner.module.geo.dto.GeoItem;

import java.util.List;

public interface GeoService {
    List<GeoItem> geocodeTripItems(Long userId, Long tripId);
}
