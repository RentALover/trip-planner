package com.tripplanner.module.budget.dto;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class BudgetSummaryResp {
    private BigDecimal totalBudget;
    private BigDecimal itemTotal;
    private BigDecimal transportTotal;
    private BigDecimal accommodationTotal;
    private BigDecimal diningTotal;
    private BigDecimal attractionTotal;
    private BigDecimal shoppingTotal;
    private BigDecimal otherTotal;
    private BigDecimal spentTotal;
    private BigDecimal remainingBudget;
}
