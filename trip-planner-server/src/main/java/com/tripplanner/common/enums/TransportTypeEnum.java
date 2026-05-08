package com.tripplanner.common.enums;

public enum TransportTypeEnum {
    WALK("步行"),
    BUS("公交"),
    SUBWAY("地铁"),
    TAXI("出租车"),
    RIDE_HAIL("网约车"),
    SELF_DRIVE("自驾"),
    BIKE("共享单车");

    private final String label;

    TransportTypeEnum(String label) {
        this.label = label;
    }

    public String getLabel() {
        return label;
    }
}
