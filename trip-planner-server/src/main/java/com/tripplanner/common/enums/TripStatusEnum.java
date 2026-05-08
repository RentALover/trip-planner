package com.tripplanner.common.enums;

public enum TripStatusEnum {
    PLANNING("规划中"),
    COMPLETED("已完成"),
    CANCELLED("已取消");

    private final String label;

    TripStatusEnum(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }
}
