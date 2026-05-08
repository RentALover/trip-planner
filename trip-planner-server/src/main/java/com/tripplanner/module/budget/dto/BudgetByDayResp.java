package com.tripplanner.module.budget.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
public class BudgetByDayResp {
    private Long dayId;
    private Integer dayNumber;
    private LocalDate date;
    private BigDecimal itemCost;
    private BigDecimal transportCost;
    private BigDecimal dayTotal;
}
