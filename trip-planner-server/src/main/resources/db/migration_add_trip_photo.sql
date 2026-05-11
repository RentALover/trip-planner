-- Migration: 创建相册表
CREATE TABLE IF NOT EXISTS `trip_photo` (
    `id`          BIGINT       NOT NULL AUTO_INCREMENT  COMMENT '照片ID',
    `trip_id`     BIGINT       NOT NULL                 COMMENT '所属行程ID',
    `url`         VARCHAR(500) NOT NULL                 COMMENT 'OSS 原图 URL',
    `location`    VARCHAR(200) DEFAULT NULL             COMMENT '拍摄地点',
    `photo_type`  VARCHAR(30)  DEFAULT 'OTHER'          COMMENT '类型: LANDSCAPE/PORTRAIT/FOOD/SELFIE/OTHER',
    `is_featured` TINYINT(1)   NOT NULL DEFAULT 0       COMMENT '是否精选',
    `sort_order`  INT          NOT NULL DEFAULT 0       COMMENT '排序',
    `create_time` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `deleted`     TINYINT(1)   NOT NULL DEFAULT 0       COMMENT '逻辑删除',
    PRIMARY KEY (`id`),
    KEY `idx_trip_id` (`trip_id`),
    CONSTRAINT `fk_photo_trip` FOREIGN KEY (`trip_id`) REFERENCES `trip`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='相册照片表';
