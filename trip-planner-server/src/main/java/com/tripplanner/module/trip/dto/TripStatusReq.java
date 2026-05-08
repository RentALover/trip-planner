package com.tripplanner.module.trip.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class TripStatusReq {
    @NotBlank(message = "状态不能为空")
    private String status;
}
