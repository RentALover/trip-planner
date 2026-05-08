package com.tripplanner.common.enums;

public enum ChecklistCategoryEnum {
    DOCUMENT("证件"),
    LUGGAGE("行李"),
    ELECTRONICS("电子设备"),
    CLOTHING("衣物"),
    TOILETRY("洗漱用品"),
    MEDICAL("医疗"),
    OTHER("其他");

    private final String label;

    ChecklistCategoryEnum(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }
}
