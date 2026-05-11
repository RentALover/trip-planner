package com.tripplanner.module.export.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.tripplanner.common.BusinessException;
import com.tripplanner.module.day.entity.TripDay;
import com.tripplanner.module.day.mapper.DayMapper;
import com.tripplanner.module.export.service.ExportService;
import com.tripplanner.module.item.entity.TripItem;
import com.tripplanner.module.item.mapper.ItemMapper;
import com.tripplanner.module.transport.entity.ItemTransport;
import com.tripplanner.module.transport.mapper.TransportMapper;
import com.tripplanner.module.trip.entity.Trip;
import com.tripplanner.module.trip.mapper.TripMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ExportServiceImpl implements ExportService {

    private final TripMapper tripMapper;
    private final DayMapper dayMapper;
    private final ItemMapper itemMapper;
    private final TransportMapper transportMapper;

    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("MM/dd");
    private static final DateTimeFormatter TIME_FMT = DateTimeFormatter.ofPattern("HH:mm");

    @Override
    public String exportText(Long userId, Long tripId) {
        Trip trip = validateOwnership(userId, tripId);

        StringBuilder sb = new StringBuilder();
        sb.append("# ").append(trip.getTripName()).append("\n\n");
        sb.append("**").append(trip.getDestination()).append("**");
        sb.append(" | ").append(trip.getStartDate()).append(" ~ ").append(trip.getEndDate());
        sb.append(" | ").append(trip.getNumPeople()).append("人");
        if (trip.getTotalBudget() != null) {
            sb.append(" | 预算 ¥").append(trip.getTotalBudget());
        }
        sb.append("\n");
        if (trip.getNotes() != null && !trip.getNotes().isBlank()) {
            sb.append("\n> ").append(trip.getNotes()).append("\n");
        }
        sb.append("\n---\n");

        List<TripDay> days = dayMapper.selectList(
                new LambdaQueryWrapper<TripDay>()
                        .eq(TripDay::getTripId, tripId)
                        .orderByAsc(TripDay::getDayNumber));

        for (TripDay day : days) {
            sb.append("\n## Day ").append(day.getDayNumber())
                    .append(" — ").append(day.getDate().format(DATE_FMT)).append("\n");
            if (day.getNotes() != null && !day.getNotes().isBlank()) {
                sb.append("> ").append(day.getNotes()).append("\n");
            }
            sb.append("\n");

            List<TripItem> items = itemMapper.selectList(
                    new LambdaQueryWrapper<TripItem>()
                            .eq(TripItem::getDayId, day.getId())
                            .orderByAsc(TripItem::getSortOrder));

            for (int i = 0; i < items.size(); i++) {
                TripItem item = items.get(i);
                String emoji = getItemEmoji(item.getItemType());

                sb.append("### ").append(emoji).append(" ").append(item.getTitle()).append("\n\n");
                if (item.getStartTime() != null) {
                    sb.append("- 🕐 ").append(item.getStartTime().format(TIME_FMT));
                    if (item.getEndTime() != null) {
                        sb.append(" ~ ").append(item.getEndTime().format(TIME_FMT));
                    }
                    sb.append("\n");
                }
                if (item.getLocation() != null && !item.getLocation().isBlank()) {
                    sb.append("- 📍 ").append(item.getLocation()).append("\n");
                }
                if (item.getCost() != null && item.getCost().compareTo(BigDecimal.ZERO) > 0) {
                    sb.append("- 💰 ¥").append(item.getCost()).append("\n");
                }
                if (item.getDescription() != null && !item.getDescription().isBlank()) {
                    sb.append("- 📝 ").append(item.getDescription()).append("\n");
                }
                sb.append("\n");

                // Transport to next item
                if (i < items.size() - 1) {
                    List<ItemTransport> transports = transportMapper.selectList(
                            new LambdaQueryWrapper<ItemTransport>()
                                    .eq(ItemTransport::getDayId, day.getId())
                                    .eq(ItemTransport::getFromItemId, item.getId())
                                    .eq(ItemTransport::getToItemId, items.get(i + 1).getId())
                                    .orderByAsc(ItemTransport::getSortOrder));
                    for (ItemTransport t : transports) {
                        sb.append("> 🚏 **").append(getTransportLabel(t.getTransportType())).append("**");
                        if (t.getTransportNumber() != null && !t.getTransportNumber().isBlank()) {
                            sb.append(" `").append(t.getTransportNumber()).append("`");
                        }
                        if (t.getDepartureStation() != null && t.getArrivalStation() != null) {
                            sb.append("  ").append(t.getDepartureStation()).append(" → ").append(t.getArrivalStation());
                        }
                        if (t.getEstimatedDuration() != null) {
                            sb.append(" · ").append(formatDuration(t.getEstimatedDuration()));
                        }
                        if (t.getCost() != null && t.getCost().compareTo(BigDecimal.ZERO) > 0) {
                            sb.append(" · ¥").append(t.getCost());
                        }
                        sb.append("\n");
                    }
                    sb.append("\n");
                }
            }
        }

        sb.append("---\n\n*Exported by Wanderlog*\n");
        return sb.toString();
    }

    @Override
    public String exportJson(Long userId, Long tripId) {
        Trip trip = validateOwnership(userId, tripId);
        return "{\"tripId\":" + trip.getId() + "}";
    }

    private Trip validateOwnership(Long userId, Long tripId) {
        Trip trip = tripMapper.selectById(tripId);
        if (trip == null) throw BusinessException.notFound("行程不存在");
        if (!trip.getUserId().equals(userId)) throw BusinessException.forbidden("无权操作此行程");
        return trip;
    }

    private String getItemEmoji(String type) {
        return switch (type) {
            case "TRANSPORT" -> "🚗";
            case "ACCOMMODATION" -> "🏨";
            case "DINING" -> "🍽️";
            case "ATTRACTION" -> "🎯";
            case "SHOPPING" -> "🛍️";
            default -> "📌";
        };
    }

    private String getTransportLabel(String type) {
        return switch (type) {
            case "WALK" -> "步行";
            case "BUS" -> "公交";
            case "SUBWAY" -> "地铁";
            case "TAXI" -> "出租车/网约车";
            case "RIDE_HAIL" -> "网约车";
            case "SELF_DRIVE" -> "自驾";
            case "BIKE" -> "单车";
            case "FLIGHT" -> "✈️ 航班";
            case "TRAIN" -> "🚄 火车/高铁";
            default -> "交通";
        };
    }

    private String formatDuration(int minutes) {
        if (minutes < 60) return minutes + "分钟";
        int h = minutes / 60;
        int m = minutes % 60;
        return m > 0 ? h + "小时" + m + "分钟" : h + "小时";
    }
}
