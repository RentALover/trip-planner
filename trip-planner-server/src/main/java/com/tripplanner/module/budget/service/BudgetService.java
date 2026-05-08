package com.tripplanner.module.budget.service;

import com.tripplanner.module.budget.dto.BudgetByCategoryResp;
import com.tripplanner.module.budget.dto.BudgetByDayResp;
import com.tripplanner.module.budget.dto.BudgetSummaryResp;

import java.util.List;

public interface BudgetService {
    BudgetSummaryResp getSummary(Long userId, Long tripId);
    List<BudgetByDayResp> getByDay(Long userId, Long tripId);
    List<BudgetByCategoryResp> getByCategory(Long userId, Long tripId);
}
