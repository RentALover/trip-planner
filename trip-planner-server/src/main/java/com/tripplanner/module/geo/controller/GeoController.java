package com.tripplanner.module.geo.controller;

import com.tripplanner.common.Result;
import com.tripplanner.module.geo.dto.GeoItem;
import com.tripplanner.module.geo.service.GeoService;
import com.tripplanner.util.UserContextHolder;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/trips/{tripId}")
@RequiredArgsConstructor
public class GeoController {

    private final GeoService geoService;

    @GetMapping("/geocode")
    public Result<List<GeoItem>> geocodeItems(@PathVariable Long tripId) {
        return Result.success(geoService.geocodeTripItems(UserContextHolder.getUserId(), tripId));
    }
}
