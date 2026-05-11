package com.tripplanner.module.weather.service;

import com.tripplanner.module.weather.dto.DailyForecast;

import java.time.LocalDate;
import java.util.List;

public interface WeatherService {
    List<DailyForecast> forecast(String city, LocalDate start, LocalDate end);
}
