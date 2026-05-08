package com.tripplanner.common.enums;

public enum ItemTypeEnum {
    TRANSPORT("交通"),
    ACCOMMODATION("住宿"),
    DINING("餐饮"),
    ATTRACTION("景点/游玩"),
    SHOPPING("购物"),
    OTHER("其他");

    private final String label;

    ItemTypeEnum(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }
}
