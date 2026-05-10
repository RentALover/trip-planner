-- ============================================================
-- 行程DIY规划应用 - 数据库建表脚本
-- ============================================================

CREATE DATABASE IF NOT EXISTS `trip_planner`
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE `trip_planner`;

-- ============================================================
-- 1. 用户表
-- ============================================================
CREATE TABLE IF NOT EXISTS `user` (
    `id`            BIGINT       NOT NULL AUTO_INCREMENT  COMMENT '用户ID',
    `username`      VARCHAR(50)  NOT NULL                 COMMENT '用户名',
    `password`      VARCHAR(255) NOT NULL                 COMMENT '密码 (BCrypt)',
    `nickname`      VARCHAR(50)  DEFAULT NULL             COMMENT '昵称',
    `email`         VARCHAR(100) DEFAULT NULL             COMMENT '邮箱',
    `phone`         VARCHAR(20)  DEFAULT NULL             COMMENT '手机号',
    `avatar_url`    VARCHAR(255) DEFAULT NULL             COMMENT '头像URL',
    `bio`           VARCHAR(500) DEFAULT NULL             COMMENT '个人简介',
    `create_time`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted`       TINYINT(1)   NOT NULL DEFAULT 0       COMMENT '逻辑删除 0-正常 1-删除',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- ============================================================
-- 2. 行程表
-- ============================================================
CREATE TABLE IF NOT EXISTS `trip` (
    `id`              BIGINT       NOT NULL AUTO_INCREMENT  COMMENT '行程ID',
    `user_id`         BIGINT       NOT NULL                 COMMENT '所属用户ID',
    `trip_name`       VARCHAR(100) NOT NULL                 COMMENT '行程名称',
    `destination`     VARCHAR(200) NOT NULL                 COMMENT '目的地',
    `start_date`      DATE         NOT NULL                 COMMENT '出发日期',
    `end_date`        DATE         NOT NULL                 COMMENT '返程日期',
    `num_people`      INT          DEFAULT 1                COMMENT '出行人数',
    `notes`           TEXT         DEFAULT NULL             COMMENT '备注',
    `status`          VARCHAR(20)  NOT NULL DEFAULT 'PLANNING' COMMENT '行程状态: PLANNING/COMPLETED/CANCELLED',
    `total_budget`    DECIMAL(12,2) DEFAULT NULL            COMMENT '总预算目标 (用户设定)',
    `cover_image_url` VARCHAR(255) DEFAULT NULL             COMMENT '封面图URL',
    `create_time`     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time`     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted`         TINYINT(1)   NOT NULL DEFAULT 0       COMMENT '逻辑删除',
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_status` (`status`),
    KEY `idx_start_date` (`start_date`),
    CONSTRAINT `fk_trip_user` FOREIGN KEY (`user_id`) REFERENCES `user`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='行程表';

-- ============================================================
-- 3. 行程日程表 (按天拆分)
-- ============================================================
CREATE TABLE IF NOT EXISTS `trip_day` (
    `id`          BIGINT      NOT NULL AUTO_INCREMENT  COMMENT '日程ID',
    `trip_id`     BIGINT      NOT NULL                 COMMENT '所属行程ID',
    `day_number`  INT         NOT NULL                 COMMENT '第几天 (从1开始)',
    `date`        DATE        NOT NULL                 COMMENT '具体日期',
    `notes`       TEXT        DEFAULT NULL             COMMENT '当日备注',
    `sort_order`  INT         NOT NULL DEFAULT 0       COMMENT '排序',
    `create_time` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted`     TINYINT(1)  NOT NULL DEFAULT 0       COMMENT '逻辑删除',
    PRIMARY KEY (`id`),
    KEY `idx_trip_id` (`trip_id`),
    KEY `idx_date` (`date`),
    UNIQUE KEY `uk_trip_day` (`trip_id`, `day_number`),
    CONSTRAINT `fk_day_trip` FOREIGN KEY (`trip_id`) REFERENCES `trip`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='行程日程表';

-- ============================================================
-- 4. 行程项表 — 统一存储所有类型
-- ============================================================
CREATE TABLE IF NOT EXISTS `trip_item` (
    `id`            BIGINT       NOT NULL AUTO_INCREMENT  COMMENT '行程项ID',
    `day_id`        BIGINT       NOT NULL                 COMMENT '所属日程ID',
    `trip_id`       BIGINT       NOT NULL                 COMMENT '所属行程ID (冗余，便于跨天查询)',
    `item_type`     VARCHAR(20)  NOT NULL                 COMMENT '类型: TRANSPORT/ACCOMMODATION/DINING/ATTRACTION/SHOPPING/OTHER',
    `title`         VARCHAR(200) NOT NULL                 COMMENT '标题 (景点名/餐厅名/酒店名等)',
    `description`   TEXT         DEFAULT NULL             COMMENT '描述/备注',
    `start_time`    TIME         DEFAULT NULL             COMMENT '开始时间',
    `end_time`      TIME         DEFAULT NULL             COMMENT '结束时间',
    `location`      VARCHAR(300) DEFAULT NULL             COMMENT '地点/地址',
    `cost`          DECIMAL(12,2) DEFAULT 0.00            COMMENT '费用',
    `item_details`  JSON         DEFAULT NULL             COMMENT '类型扩展字段 (JSON格式)',
    `sort_order`    DOUBLE       NOT NULL DEFAULT 0       COMMENT '排序值 (DOUBLE类型，支持小数插值)',
    `image_url`     VARCHAR(255) DEFAULT NULL             COMMENT '图片URL',
    `create_time`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted`       TINYINT(1)   NOT NULL DEFAULT 0       COMMENT '逻辑删除',
    PRIMARY KEY (`id`),
    KEY `idx_day_id` (`day_id`),
    KEY `idx_trip_id` (`trip_id`),
    KEY `idx_type` (`item_type`),
    KEY `idx_sort_order` (`day_id`, `sort_order`),
    CONSTRAINT `fk_item_day` FOREIGN KEY (`day_id`) REFERENCES `trip_day`(`id`),
    CONSTRAINT `fk_item_trip` FOREIGN KEY (`trip_id`) REFERENCES `trip`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='行程项表';

-- ============================================================
-- 5. 行程项间交通表 — 连接相邻行程项
-- ============================================================
CREATE TABLE IF NOT EXISTS `item_transport` (
    `id`                  BIGINT       NOT NULL AUTO_INCREMENT  COMMENT '交通ID',
    `day_id`              BIGINT       NOT NULL                 COMMENT '所属日程ID',
    `trip_id`             BIGINT       NOT NULL                 COMMENT '所属行程ID (冗余)',
    `from_item_id`        BIGINT       NOT NULL                 COMMENT '出发行程项ID',
    `to_item_id`          BIGINT       NOT NULL                 COMMENT '到达行程项ID',
    `transport_type`      VARCHAR(20)  NOT NULL                 COMMENT '交通方式: WALK/BUS/SUBWAY/TAXI/RIDE_HAIL/SELF_DRIVE/BIKE',
    `departure_time`      TIME         DEFAULT NULL             COMMENT '出发时间',
    `estimated_duration`  INT          DEFAULT NULL             COMMENT '预计耗时 (分钟)',
    `cost`                DECIMAL(12,2) DEFAULT 0.00            COMMENT '交通费用',
    `transport_number`    VARCHAR(32)  DEFAULT NULL             COMMENT '班次号 (航班号/车次号等)',
    `departure_station`   VARCHAR(200) DEFAULT NULL             COMMENT '出发站/起点',
    `arrival_station`     VARCHAR(200) DEFAULT NULL             COMMENT '到达站/终点',
    `route_info`          VARCHAR(500) DEFAULT NULL             COMMENT '路线信息 (公交路线/地铁线路等)',
    `notes`               TEXT         DEFAULT NULL             COMMENT '备注',
    `sort_order`          DOUBLE       NOT NULL DEFAULT 0       COMMENT '排序值 (等于from_item的sort_order + 0.5)',
    `create_time`         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time`         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted`             TINYINT(1)   NOT NULL DEFAULT 0       COMMENT '逻辑删除',
    PRIMARY KEY (`id`),
    KEY `idx_day_id` (`day_id`),
    KEY `idx_from_item` (`from_item_id`),
    KEY `idx_to_item` (`to_item_id`),
    UNIQUE KEY `uk_from_to_sort` (`from_item_id`, `to_item_id`, `sort_order`, `deleted`),
    CONSTRAINT `fk_transport_day` FOREIGN KEY (`day_id`) REFERENCES `trip_day`(`id`),
    CONSTRAINT `fk_transport_trip` FOREIGN KEY (`trip_id`) REFERENCES `trip`(`id`),
    CONSTRAINT `fk_transport_from` FOREIGN KEY (`from_item_id`) REFERENCES `trip_item`(`id`),
    CONSTRAINT `fk_transport_to` FOREIGN KEY (`to_item_id`) REFERENCES `trip_item`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='行程项间交通表';

-- ============================================================
-- 6. 备忘录清单表
-- ============================================================
CREATE TABLE IF NOT EXISTS `checklist` (
    `id`          BIGINT       NOT NULL AUTO_INCREMENT  COMMENT '清单项ID',
    `trip_id`     BIGINT       NOT NULL                 COMMENT '所属行程ID',
    `title`       VARCHAR(200) NOT NULL                 COMMENT '事项标题',
    `category`    VARCHAR(30)  NOT NULL DEFAULT 'OTHER' COMMENT '分类: DOCUMENT/LUGGAGE/ELECTRONICS/CLOTHING/TOILETRY/MEDICAL/OTHER',
    `is_checked`  TINYINT(1)   NOT NULL DEFAULT 0       COMMENT '是否已勾选',
    `sort_order`  INT          NOT NULL DEFAULT 0       COMMENT '排序',
    `create_time` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted`     TINYINT(1)   NOT NULL DEFAULT 0       COMMENT '逻辑删除',
    PRIMARY KEY (`id`),
    KEY `idx_trip_id` (`trip_id`),
    KEY `idx_category` (`category`),
    CONSTRAINT `fk_checklist_trip` FOREIGN KEY (`trip_id`) REFERENCES `trip`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='备忘录清单表';
