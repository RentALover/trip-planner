package com.tripplanner.module.weather.service.impl;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.tripplanner.module.weather.dto.DailyForecast;
import com.tripplanner.module.weather.service.WeatherService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
public class WeatherServiceImpl implements WeatherService {

    private final RestTemplate restTemplate = new RestTemplate();
    private final ObjectMapper objectMapper = new ObjectMapper();

    private static final Map<String, double[]> CITY_COORDS = Map.ofEntries(
        Map.entry("北京", new double[]{39.90, 116.41}),
        Map.entry("上海", new double[]{31.23, 121.47}),
        Map.entry("广州", new double[]{23.13, 113.26}),
        Map.entry("深圳", new double[]{22.54, 114.06}),
        Map.entry("成都", new double[]{30.57, 104.07}),
        Map.entry("重庆", new double[]{29.56, 106.55}),
        Map.entry("杭州", new double[]{30.27, 120.15}),
        Map.entry("南京", new double[]{32.06, 118.80}),
        Map.entry("武汉", new double[]{30.58, 114.30}),
        Map.entry("西安", new double[]{34.26, 108.94}),
        Map.entry("天津", new double[]{39.14, 117.18}),
        Map.entry("苏州", new double[]{31.30, 120.62}),
        Map.entry("长沙", new double[]{28.23, 112.94}),
        Map.entry("郑州", new double[]{34.75, 113.63}),
        Map.entry("青岛", new double[]{36.07, 120.38}),
        Map.entry("大连", new double[]{38.91, 121.61}),
        Map.entry("厦门", new double[]{24.49, 118.09}),
        Map.entry("昆明", new double[]{25.04, 102.68}),
        Map.entry("三亚", new double[]{18.25, 109.51}),
        Map.entry("哈尔滨", new double[]{45.80, 126.54}),
        Map.entry("桂林", new double[]{25.27, 110.29}),
        Map.entry("丽江", new double[]{26.86, 100.23}),
        Map.entry("拉萨", new double[]{29.65, 91.12}),
        Map.entry("乌鲁木齐", new double[]{43.83, 87.62}),
        Map.entry("香港", new double[]{22.32, 114.17}),
        Map.entry("澳门", new double[]{22.19, 113.54}),
        Map.entry("台北", new double[]{25.03, 121.57}),
        Map.entry("呼和浩特", new double[]{40.82, 111.75}),
        Map.entry("南宁", new double[]{22.82, 108.37}),
        Map.entry("贵阳", new double[]{26.65, 106.63}),
        Map.entry("兰州", new double[]{36.06, 103.83}),
        Map.entry("西宁", new double[]{36.62, 101.78}),
        Map.entry("银川", new double[]{38.47, 106.26}),
        Map.entry("海口", new double[]{20.02, 110.35}),
        Map.entry("福州", new double[]{26.07, 119.30}),
        Map.entry("合肥", new double[]{31.82, 117.23}),
        Map.entry("南昌", new double[]{28.68, 115.89}),
        Map.entry("济南", new double[]{36.65, 117.00}),
        Map.entry("沈阳", new double[]{41.80, 123.43}),
        Map.entry("长春", new double[]{43.88, 125.32}),
        Map.entry("太原", new double[]{37.87, 112.55}),
        Map.entry("石家庄", new double[]{38.04, 114.49}),
        Map.entry("洛阳", new double[]{34.66, 112.45}),
        Map.entry("大理", new double[]{25.61, 100.27}),
        Map.entry("张家界", new double[]{29.12, 110.48}),
        Map.entry("九寨沟", new double[]{33.26, 103.90}),
        Map.entry("黄山", new double[]{29.72, 118.34}),
        Map.entry("敦煌", new double[]{40.14, 94.66}),
        Map.entry("稻城", new double[]{29.04, 100.30}),
        Map.entry("清河", new double[]{37.02, 115.69}),
        Map.entry("雄安", new double[]{39.02, 115.99})
    );

    @Override
    public List<DailyForecast> forecast(String city, LocalDate start, LocalDate end) {
        double[] coords = resolveCoords(city);
        if (coords == null) {
            log.warn("Cannot resolve coordinates for city: {}", city);
            return List.of();
        }

        String url = String.format(
            "https://api.open-meteo.com/v1/forecast?latitude=%.4f&longitude=%.4f&daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max,weathercode&timezone=Asia/Shanghai&start_date=%s&end_date=%s",
            coords[0], coords[1], start, end);

        try {
            String json = restTemplate.getForObject(url, String.class);
            JsonNode root = objectMapper.readTree(json);
            JsonNode daily = root.get("daily");
            if (daily == null) return List.of();

            List<DailyForecast> result = new ArrayList<>();
            var dates = daily.get("time");
            var maxTemps = daily.get("temperature_2m_max");
            var minTemps = daily.get("temperature_2m_min");
            var precip = daily.get("precipitation_probability_max");
            var codes = daily.get("weathercode");

            if (dates == null || !dates.isArray()) return result;

            for (int i = 0; i < dates.size(); i++) {
                DailyForecast f = new DailyForecast();
                f.setDate(dates.get(i).asText());
                int code = codes != null ? codes.get(i).asInt() : 0;
                f.setWeatherCode(code);
                f.setWeatherDesc(weatherCodeDesc(code));
                f.setIcon(weatherCodeIcon(code));
                f.setTempMax(maxTemps != null ? maxTemps.get(i).asDouble() : 0);
                f.setTempMin(minTemps != null ? minTemps.get(i).asDouble() : 0);
                f.setPrecipitationProbability(precip != null ? precip.get(i).asInt() : 0);
                result.add(f);
            }
            return result;
        } catch (Exception e) {
            log.warn("Weather fetch failed for {}: {}", city, e.getMessage());
            return List.of();
        }
    }

    private double[] resolveCoords(String city) {
        // Direct match
        if (CITY_COORDS.containsKey(city)) return CITY_COORDS.get(city);
        // Match by prefix (e.g. "北京市" matches "北京")
        for (var entry : CITY_COORDS.entrySet()) {
            if (city.contains(entry.getKey())) return entry.getValue();
        }
        return null;
    }

    private String weatherCodeDesc(int code) {
        return switch (code) {
            case 0 -> "晴";
            case 1, 2 -> "多云";
            case 3 -> "阴";
            case 45, 48 -> "雾";
            case 51, 53, 55 -> "小雨";
            case 61, 63, 65 -> "雨";
            case 71, 73, 75 -> "雪";
            case 80, 81, 82 -> "阵雨";
            case 95, 96, 99 -> "雷暴";
            default -> "未知";
        };
    }

    private String weatherCodeIcon(int code) {
        if (code == 0) return "☀️";
        if (code <= 2) return "⛅";
        if (code == 3) return "☁️";
        if (code <= 48) return "🌫️";
        if (code <= 55) return "🌧️";
        if (code <= 65) return "🌧️";
        if (code <= 75) return "❄️";
        if (code <= 82) return "🌦️";
        if (code <= 99) return "⛈️";
        return "❓";
    }
}
