package com.tripplanner.module.photo.dto;

import lombok.Data;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
public class PhotoAlbumResp {
    private Long id;
    private Long tripId;
    private String tripName;
    private String tripDestination;
    private LocalDate tripStartDate;
    private String url;
    private String thumbnailUrl;
    private String location;
    private String photoType;
    private Boolean isFeatured;
    private Integer sortOrder;
    private LocalDateTime createTime;
}
