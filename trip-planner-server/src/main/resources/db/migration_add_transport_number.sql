-- Migration: 为 item_transport 表新增 transport_number 字段
-- 用于存储航班号/高铁车次等班次号
ALTER TABLE item_transport ADD COLUMN transport_number VARCHAR(32) DEFAULT NULL COMMENT '班次号' AFTER transport_type;
