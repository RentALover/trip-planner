package com.tripplanner.module.budget.dto;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class BudgetByCategoryResp {
    private String category;
    private Long count;
    private BigDecimal totalCost;
    private BigDecimal percentage;
}
