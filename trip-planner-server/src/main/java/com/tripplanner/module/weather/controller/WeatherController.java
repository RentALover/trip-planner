package com.tripplanner.module.weather.controller;

import com.tripplanner.common.Result;
import com.tripplanner.module.weather.dto.DailyForecast;
import com.tripplanner.module.weather.service.WeatherService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/v1/weather")
@RequiredArgsConstructor
public class WeatherController {

    private final WeatherService weatherService;

    @GetMapping("/forecast")
    public Result<List<DailyForecast>> forecast(@RequestParam String city,
                                                 @RequestParam LocalDate start,
                                                 @RequestParam LocalDate end) {
        return Result.success(weatherService.forecast(city, start, end));
    }
}
