package com.tripplanner.module.geo.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.tripplanner.common.BusinessException;
import com.tripplanner.module.day.entity.TripDay;
import com.tripplanner.module.day.mapper.DayMapper;
import com.tripplanner.module.geo.dto.GeoItem;
import com.tripplanner.module.geo.service.GeoService;
import com.tripplanner.module.item.entity.TripItem;
import com.tripplanner.module.item.mapper.ItemMapper;
import com.tripplanner.module.trip.entity.Trip;
import com.tripplanner.module.trip.mapper.TripMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.net.HttpURLConnection;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class GeoServiceImpl implements GeoService {

    private final TripMapper tripMapper;
    private final DayMapper dayMapper;
    private final ItemMapper itemMapper;
    private final ObjectMapper objectMapper = new ObjectMapper();

    private static final RestTemplate restTemplate = createTimeoutRestTemplate();
    private final Map<String, double[]> cache = new HashMap<>();

    private static final Map<String, double[]> GEO_COORDS = new HashMap<>();

    // Hardcoded coordinates for common Chinese locations — instant lookup, no API call
    static {
        initCoords();
    }

    private static void initCoords() {
        // Cities
        put("北京", 39.90, 116.41); put("北京市", 39.90, 116.41);
        put("上海", 31.23, 121.47); put("上海市", 31.23, 121.47);
        put("广州", 23.13, 113.26); put("广州市", 23.13, 113.26);
        put("深圳", 22.54, 114.06); put("深圳市", 22.54, 114.06);
        put("成都", 30.57, 104.07); put("成都市", 30.57, 104.07);
        put("重庆", 29.56, 106.55); put("重庆市", 29.56, 106.55);
        put("杭州", 30.27, 120.15); put("杭州市", 30.27, 120.15);
        put("南京", 32.06, 118.80); put("南京市", 32.06, 118.80);
        put("武汉", 30.58, 114.30); put("武汉市", 30.58, 114.30);
        put("西安", 34.26, 108.94); put("西安市", 34.26, 108.94);
        put("天津", 39.14, 117.18); put("天津市", 39.14, 117.18);
        put("苏州", 31.30, 120.62); put("苏州市", 31.30, 120.62);
        put("长沙", 28.23, 112.94); put("长沙市", 28.23, 112.94);
        put("郑州", 34.75, 113.63); put("郑州市", 34.75, 113.63);
        put("青岛", 36.07, 120.38); put("青岛市", 36.07, 120.38);
        put("大连", 38.91, 121.61); put("大连市", 38.91, 121.61);
        put("厦门", 24.49, 118.09); put("厦门市", 24.49, 118.09);
        put("昆明", 25.04, 102.68); put("昆明市", 25.04, 102.68);
        put("三亚", 18.25, 109.51);
        put("哈尔滨", 45.80, 126.54); put("哈尔滨市", 45.80, 126.54);
        put("桂林", 25.27, 110.29);
        put("丽江", 26.86, 100.23);
        put("大理", 25.61, 100.27);
        put("拉萨", 29.65, 91.12);
        put("乌鲁木齐", 43.83, 87.62);
        put("香港", 22.32, 114.17);
        put("澳门", 22.19, 113.54);
        put("台北", 25.03, 121.57);
        put("合肥", 31.82, 117.23); put("合肥市", 31.82, 117.23);
        put("南昌", 28.68, 115.89); put("南昌市", 28.68, 115.89);
        put("济南", 36.65, 117.00); put("济南市", 36.65, 117.00);
        put("沈阳", 41.80, 123.43); put("沈阳市", 41.80, 123.43);
        put("长春", 43.88, 125.32); put("长春市", 43.88, 125.32);
        put("太原", 37.87, 112.55); put("太原市", 37.87, 112.55);
        put("石家庄", 38.04, 114.49); put("石家庄市", 38.04, 114.49);
        put("福州", 26.07, 119.30); put("福州市", 26.07, 119.30);
        put("贵阳", 26.65, 106.63); put("贵阳市", 26.65, 106.63);
        put("兰州", 36.06, 103.83); put("兰州市", 36.06, 103.83);
        put("南宁", 22.82, 108.37); put("南宁市", 22.82, 108.37);
        put("呼和浩特", 40.82, 111.75); put("呼和浩特市", 40.82, 111.75);
        put("西宁", 36.62, 101.78); put("西宁市", 36.62, 101.78);
        put("银川", 38.47, 106.26); put("银川市", 38.47, 106.26);
        put("海口", 20.02, 110.35); put("海口市", 20.02, 110.35);
        put("洛阳", 34.66, 112.45);
        put("张家界", 29.12, 110.48);
        put("九寨沟", 33.26, 103.90);
        put("黄山", 29.72, 118.34);
        put("敦煌", 40.14, 94.66);
        put("稻城", 29.04, 100.30);
        put("香格里拉", 27.83, 99.70);
        put("漠河", 53.48, 122.37);

        // Tourist spots — Beijing
        put("故宫", 39.92, 116.40); put("故宫博物院", 39.92, 116.40); put("紫禁城", 39.92, 116.40);
        put("天安门", 39.91, 116.40); put("天安门广场", 39.91, 116.40);
        put("颐和园", 39.99, 116.27);
        put("长城", 40.36, 116.02); put("八达岭长城", 40.36, 116.02); put("慕田峪长城", 40.44, 116.56);
        put("天坛", 39.88, 116.41); put("天坛公园", 39.88, 116.41);
        put("雍和宫", 39.95, 116.42);
        put("圆明园", 40.01, 116.30);
        put("南锣鼓巷", 39.94, 116.40);
        put("三里屯", 39.93, 116.46);
        put("王府井", 39.91, 116.41); put("王府井百货", 39.91, 116.41);
        put("鸟巢", 39.99, 116.39); put("国家体育场", 39.99, 116.39);
        put("水立方", 39.99, 116.38);
        put("景山公园", 39.92, 116.39);
        put("什刹海", 39.94, 116.38);
        put("北京首都国际机场", 40.08, 116.58); put("北京首都机场", 40.08, 116.58);
        put("北京大兴国际机场", 39.51, 116.41); put("北京大兴机场", 39.51, 116.41);
        put("北京站", 39.90, 116.43); put("北京西站", 39.89, 116.32);
        put("北京南站", 39.86, 116.38);

        // Shanghai
        put("外滩", 31.24, 121.49);
        put("东方明珠", 31.24, 121.50);
        put("陆家嘴", 31.24, 121.50);
        put("南京路步行街", 31.23, 121.47); put("南京路", 31.23, 121.47);
        put("上海迪士尼", 31.14, 121.66); put("迪士尼乐园", 31.14, 121.66);
        put("豫园", 31.23, 121.49);
        put("上海虹桥机场", 31.20, 121.34); put("虹桥机场", 31.20, 121.34);
        put("上海浦东机场", 31.14, 121.81); put("浦东机场", 31.14, 121.81);
        put("上海虹桥站", 31.19, 121.32);
        put("上海站", 31.25, 121.46); put("上海火车站", 31.25, 121.46);

        // Chengdu
        put("宽窄巷子", 30.67, 104.05);
        put("大熊猫基地", 30.73, 104.15); put("大熊猫繁育研究基地", 30.73, 104.15); put("熊猫基地", 30.73, 104.15);
        put("锦里", 30.65, 104.05);
        put("武侯祠", 30.65, 104.05);
        put("杜甫草堂", 30.66, 104.03);
        put("青城山", 30.90, 103.57);
        put("都江堰", 31.00, 103.62);
        put("成都东站", 30.63, 104.14);
        put("成都双流机场", 30.58, 103.95); put("双流机场", 30.58, 103.95);
        put("天府机场", 30.32, 104.44); put("成都天府机场", 30.32, 104.44);

        // Other common spots
        put("西湖", 30.24, 120.14); put("杭州西湖", 30.24, 120.14);
        put("秦淮河", 32.02, 118.79); put("夫子庙", 32.02, 118.79);
        put("兵马俑", 34.38, 109.27); put("秦始皇兵马俑", 34.38, 109.27);
        put("洪崖洞", 29.56, 106.57);
        put("鼓浪屿", 24.45, 118.07);
        put("张家界国家森林公园", 29.33, 110.42);
        put("黄果树瀑布", 25.99, 105.67);
        put("布达拉宫", 29.66, 91.12);
        put("大雁塔", 34.22, 108.96);
        put("黄鹤楼", 30.55, 114.30);
        put("滕王阁", 28.68, 115.88);
        put("岳麓书院", 28.18, 112.93);
    }

    private static void put(String name, double lat, double lng) {
        GEO_COORDS.put(name, new double[]{lat, lng});
    }

    private static RestTemplate createTimeoutRestTemplate() {
        SimpleClientHttpRequestFactory fac = new SimpleClientHttpRequestFactory() {
            @Override
            protected void prepareConnection(HttpURLConnection conn, String method) throws java.io.IOException {
                conn.setConnectTimeout(3000);
                conn.setReadTimeout(3000);
                super.prepareConnection(conn, method);
            }
        };
        return new RestTemplate(fac);
    }

    @Override
    public List<GeoItem> geocodeTripItems(Long userId, Long tripId) {
        Trip trip = tripMapper.selectById(tripId);
        if (trip == null || !trip.getUserId().equals(userId)) {
            throw BusinessException.forbidden("无权操作此行程");
        }

        List<TripDay> days = dayMapper.selectList(
                new LambdaQueryWrapper<TripDay>().eq(TripDay::getTripId, tripId));
        Map<Long, Integer> dayNumberMap = new HashMap<>();
        for (TripDay d : days) dayNumberMap.put(d.getId(), d.getDayNumber());

        List<TripItem> items = itemMapper.selectList(
                new LambdaQueryWrapper<TripItem>()
                        .in(TripItem::getDayId, dayNumberMap.keySet())
                        .isNotNull(TripItem::getLocation)
                        .ne(TripItem::getLocation, ""));
        items.removeIf(i -> i.getLocation() == null || i.getLocation().isBlank());

        List<GeoItem> results = new ArrayList<>();

        double[] destCoords = geocode(trip.getDestination());
        if (destCoords != null) {
            GeoItem dest = new GeoItem();
            dest.setItemId(0L); dest.setTitle(trip.getDestination());
            dest.setItemType("DESTINATION"); dest.setLocation(trip.getDestination());
            dest.setLat(destCoords[0]); dest.setLng(destCoords[1]);
            dest.setDayNumber(0);
            results.add(dest);
        }

        for (TripItem item : items) {
            double[] coords = geocode(item.getLocation());
            if (coords == null) continue;
            GeoItem gi = new GeoItem();
            gi.setItemId(item.getId()); gi.setTitle(item.getTitle());
            gi.setItemType(item.getItemType()); gi.setLocation(item.getLocation());
            gi.setLat(coords[0]); gi.setLng(coords[1]);
            gi.setDayNumber(dayNumberMap.getOrDefault(item.getDayId(), 0));
            results.add(gi);
        }
        return results;
    }

    private double[] geocode(String location) {
        if (location == null || location.isBlank()) return null;

        // Try hardcoded map first (exact match)
        if (GEO_COORDS.containsKey(location)) return GEO_COORDS.get(location);

        // Try hardcoded map by contains match
        for (var e : GEO_COORDS.entrySet()) {
            if (location.contains(e.getKey()) || e.getKey().contains(location)) {
                return e.getValue();
            }
        }

        // Try cache
        if (cache.containsKey(location)) return cache.get(location);

        // Fallback: Nominatim
        try {
            String encoded = URLEncoder.encode(location, StandardCharsets.UTF_8);
            String url = "https://nominatim.openstreetmap.org/search?format=json&limit=1&q=" + encoded;
            String json = restTemplate.getForObject(url, String.class);
            if (json != null) {
                JsonNode arr = objectMapper.readTree(json);
                if (arr.isArray() && arr.size() > 0) {
                    double lat = arr.get(0).get("lat").asDouble();
                    double lng = arr.get(0).get("lon").asDouble();
                    double[] result = {lat, lng};
                    cache.put(location, result);
                    return result;
                }
            }
        } catch (Exception e) {
            log.debug("Geocode failed for {}: {}", location, e.getMessage());
        }
        return null;
    }
}
