-- Migration: 创建旅行日记表
CREATE TABLE IF NOT EXISTS `day_journal` (
    `id`          BIGINT       NOT NULL AUTO_INCREMENT  COMMENT '日记ID',
    `day_id`      BIGINT       NOT NULL                 COMMENT '所属日程ID',
    `trip_id`     BIGINT       NOT NULL                 COMMENT '所属行程ID (冗余)',
    `content`     TEXT         NOT NULL                 COMMENT '日记正文',
    `mood`        VARCHAR(30)  DEFAULT NULL             COMMENT '心情',
    `weather`     VARCHAR(30)  DEFAULT NULL             COMMENT '天气',
    `image_urls`  VARCHAR(1000) DEFAULT NULL            COMMENT '图片URL列表 (JSON数组)',
    `create_time` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted`     TINYINT(1)   NOT NULL DEFAULT 0       COMMENT '逻辑删除',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_day_id` (`day_id`),
    KEY `idx_trip_id` (`trip_id`),
    CONSTRAINT `fk_journal_day` FOREIGN KEY (`day_id`) REFERENCES `trip_day`(`id`),
    CONSTRAINT `fk_journal_trip` FOREIGN KEY (`trip_id`) REFERENCES `trip`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='旅行日记表';
