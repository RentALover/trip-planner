package com.tripplanner.module.budget.controller;

import com.tripplanner.common.Result;
import com.tripplanner.module.budget.dto.BudgetByCategoryResp;
import com.tripplanner.module.budget.dto.BudgetByDayResp;
import com.tripplanner.module.budget.dto.BudgetSummaryResp;
import com.tripplanner.module.budget.service.BudgetService;
import com.tripplanner.util.UserContextHolder;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/trips/{tripId}/budget")
@RequiredArgsConstructor
public class BudgetController {

    private final BudgetService budgetService;

    @GetMapping
    public Result<BudgetSummaryResp> getSummary(@PathVariable Long tripId) {
        return Result.success(budgetService.getSummary(UserContextHolder.getUserId(), tripId));
    }

    @GetMapping("/by-day")
    public Result<List<BudgetByDayResp>> getByDay(@PathVariable Long tripId) {
        return Result.success(budgetService.getByDay(UserContextHolder.getUserId(), tripId));
    }

    @GetMapping("/by-category")
    public Result<List<BudgetByCategoryResp>> getByCategory(@PathVariable Long tripId) {
        return Result.success(budgetService.getByCategory(UserContextHolder.getUserId(), tripId));
    }
}
