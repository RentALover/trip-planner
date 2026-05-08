package com.tripplanner.module.transport.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalTime;

@Data
public class TransportCreateReq {
    @NotNull(message = "出发行程项不能为空")
    private Long fromItemId;

    @NotNull(message = "到达行程项不能为空")
    private Long toItemId;

    @NotBlank(message = "交通方式不能为空")
    private String transportType;

    private LocalTime departureTime;
    private Integer estimatedDuration;
    private BigDecimal cost;
    private String routeInfo;
    private String notes;
}
