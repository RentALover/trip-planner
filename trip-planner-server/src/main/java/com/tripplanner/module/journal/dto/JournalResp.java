package com.tripplanner.module.journal.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class JournalResp {
    private Long id;
    private Long dayId;
    private Long tripId;
    private String content;
    private String mood;
    private String weather;
    private String imageUrls;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
}
