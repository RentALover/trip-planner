package com.tripplanner.module.photo.dto;

import lombok.Data;
import java.util.List;

@Data
public class BatchDeleteReq {
    private List<Long> ids;
}
