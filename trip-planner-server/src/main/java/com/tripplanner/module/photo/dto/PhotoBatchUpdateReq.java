package com.tripplanner.module.photo.dto;

import lombok.Data;
import java.util.List;

@Data
public class PhotoBatchUpdateReq {
    private List<Long> ids;
    private String location;
    private String photoType;
    private Boolean isFeatured;
}
