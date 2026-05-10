-- Migration: 为 item_transport 表新增起终点字段
ALTER TABLE item_transport ADD COLUMN departure_station VARCHAR(200) DEFAULT NULL COMMENT '出发站/起点' AFTER transport_number;
ALTER TABLE item_transport ADD COLUMN arrival_station VARCHAR(200) DEFAULT NULL COMMENT '到达站/终点' AFTER departure_station;
