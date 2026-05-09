-- Migration: 修改 item_transport 唯一约束，允许多段交通
ALTER TABLE item_transport DROP INDEX uk_from_to;
ALTER TABLE item_transport ADD UNIQUE KEY uk_from_to_sort (from_item_id, to_item_id, sort_order, deleted);
