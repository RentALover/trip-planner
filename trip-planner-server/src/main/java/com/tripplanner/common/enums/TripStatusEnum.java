package com.tripplanner.common.enums;

import java.util.Set;

public enum TripStatusEnum {
    PLANNING("规划中"),
    IN_PROGRESS("行程中"),
    COMPLETED("已完成"),
    CANCELLED("已取消");

    private final String label;

    TripStatusEnum(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }

    public static TripStatusEnum fromValue(String value) {
        for (TripStatusEnum e : values()) {
            if (e.name().equalsIgnoreCase(value)) return e;
        }
        return null;
    }

    /**
     * Valid transitions from this status.
     */
    public Set<TripStatusEnum> allowedTransitions() {
        return switch (this) {
            case PLANNING -> Set.of(IN_PROGRESS, CANCELLED);
            case IN_PROGRESS -> Set.of(COMPLETED, CANCELLED);
            case COMPLETED -> Set.of();
            case CANCELLED -> Set.of(PLANNING);
        };
    }
}
