package com.tripplanner.module.transport.service.impl;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.tripplanner.common.BusinessException;
import com.tripplanner.module.transport.dto.TransportLookupResult;
import com.tripplanner.module.transport.service.TransportLookupService;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.tripplanner.common.BusinessException;
import com.tripplanner.module.transport.dto.TransportLookupResult;
import com.tripplanner.module.transport.service.TransportLookupService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import javax.net.ssl.*;
import java.net.HttpURLConnection;
import java.security.cert.X509Certificate;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;

@Slf4j
@Service
public class TransportLookupServiceImpl implements TransportLookupService {

    private final RestTemplate restTemplate = createTrustAllRestTemplate();
    private final ObjectMapper objectMapper;
    private final String aviationstackKey;

    public TransportLookupServiceImpl(ObjectMapper objectMapper,
                                       @Value("${transport.lookup.aviationstack-key:}") String aviationstackKey) {
        this.objectMapper = objectMapper;
        this.aviationstackKey = aviationstackKey;
    }

    @Override
    public TransportLookupResult lookup(String type, String number, LocalDate date) {
        if ("FLIGHT".equalsIgnoreCase(type)) {
            return lookupFlight(number, date);
        } else if ("TRAIN".equalsIgnoreCase(type)) {
            return lookupTrain(number, date);
        }
        throw BusinessException.badRequest("不支持的交通类型：" + type);
    }

    private TransportLookupResult lookupFlight(String flightNumber, LocalDate date) {
        if (aviationstackKey == null || aviationstackKey.isBlank()) {
            throw BusinessException.badRequest("航班查询未配置 API Key（AVIATIONSTACK_KEY）");
        }

        String url = "https://api.aviationstack.com/v1/flights?access_key=" + aviationstackKey
                + "&flight_iata=" + flightNumber;

        try {
            String json = restTemplate.getForObject(url, String.class);
            JsonNode root = objectMapper.readTree(json);
            JsonNode data = root.get("data");

            if (data == null || !data.isArray() || data.size() == 0) {
                throw BusinessException.notFound("未找到航班 " + flightNumber + " 的信息");
            }

            JsonNode flight = data.get(0);
            JsonNode departure = flight.get("departure");
            JsonNode arrival = flight.get("arrival");

            String depAirport = departure.get("airport").asText();
            String arrAirport = arrival.get("airport").asText();
            String depScheduled = departure.get("scheduled").asText();
            String arrScheduled = arrival.get("scheduled").asText();

            LocalTime depTime = LocalTime.parse(depScheduled.substring(11, 16));
            LocalTime arrTime = LocalTime.parse(arrScheduled.substring(11, 16));

            TransportLookupResult result = new TransportLookupResult();
            result.setDepartureStation(depAirport);
            result.setArrivalStation(arrAirport);
            result.setDepartureTime(depTime.format(DateTimeFormatter.ofPattern("HH:mm")));
            result.setArrivalTime(arrTime.format(DateTimeFormatter.ofPattern("HH:mm")));
            result.setDurationMinutes((int) ChronoUnit.MINUTES.between(depTime, arrTime));
            result.setRouteInfo(flightNumber + " " + depAirport + "→" + arrAirport);
            return result;
        } catch (BusinessException e) {
            throw e;
        } catch (Exception e) {
            log.warn("Flight lookup failed for {}: {}", flightNumber, e.getMessage());
            throw BusinessException.badRequest("航班查询失败，请检查航班号是否正确");
        }
    }

    private TransportLookupResult lookupTrain(String trainNumber, LocalDate date) {
        String dateStr = date.format(DateTimeFormatter.ofPattern("yyyyMMdd"));

        try {
            String searchUrl = "https://search.12306.cn/search/v1/train/search"
                    + "?keyword=" + trainNumber + "&date=" + dateStr;
            String searchJson = restTemplate.getForObject(searchUrl, String.class);
            log.info("12306 search: {}", searchJson);
            JsonNode searchData = objectMapper.readTree(searchJson).get("data");
            if (searchData == null || !searchData.isArray() || searchData.size() == 0) {
                throw BusinessException.notFound("未找到车次 " + trainNumber);
            }

            JsonNode trainInfo = searchData.get(0);
            String fromStation = getJsonTextField(trainInfo, "from_station_name", "from_station");
            String toStation = getJsonTextField(trainInfo, "to_station_name", "to_station");

            if (fromStation == null || toStation == null) {
                throw BusinessException.notFound("车次 " + trainNumber + " 数据不完整");
            }

            TransportLookupResult result = new TransportLookupResult();
            result.setDepartureStation(fromStation);
            result.setArrivalStation(toStation);
            result.setRouteInfo(trainNumber + " " + fromStation + "→" + toStation);
            return result;
        } catch (BusinessException e) {
            throw e;
        } catch (Exception e) {
            log.warn("Train lookup failed for {}: {}", trainNumber, e.getMessage());
            throw BusinessException.badRequest("车次查询失败，请检查车次号和日期是否正确");
        }
    }

    private String getJsonTextField(JsonNode node, String... fieldNames) {
        for (String name : fieldNames) {
            if (node.has(name) && !node.get(name).isNull()) {
                return node.get(name).asText();
            }
        }
        return null;
    }

    private static RestTemplate createTrustAllRestTemplate() {
        try {
            SSLContext sc = SSLContext.getInstance("TLS");
            sc.init(null, new TrustManager[] { new X509TrustManager() {
                public void checkClientTrusted(X509Certificate[] c, String a) {}
                public void checkServerTrusted(X509Certificate[] c, String a) {}
                public X509Certificate[] getAcceptedIssuers() { return new X509Certificate[0]; }
            } }, new java.security.SecureRandom());

            SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory() {
                @Override
                protected void prepareConnection(HttpURLConnection conn, String method) throws java.io.IOException {
                    if (conn instanceof HttpsURLConnection httpsConn) {
                        httpsConn.setSSLSocketFactory(sc.getSocketFactory());
                        httpsConn.setHostnameVerifier((hostname, session) -> true);
                    }
                    super.prepareConnection(conn, method);
                }
            };
            RestTemplate rt = new RestTemplate(factory);
            rt.getInterceptors().add((request, body, execution) -> {
                request.getHeaders().set("User-Agent",
                        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36");
                return execution.execute(request, body);
            });
            return rt;
        } catch (Exception e) {
            return new RestTemplate();
        }
    }
}
