package com.tripplanner.module.weather.dto;

import lombok.Data;

@Data
public class DailyForecast {
    private String date;
    private int weatherCode;
    private String weatherDesc;
    private double tempMax;
    private double tempMin;
    private int precipitationProbability;
    private String icon;
}
