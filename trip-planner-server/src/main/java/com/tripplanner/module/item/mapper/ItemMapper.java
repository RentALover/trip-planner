package com.tripplanner.module.item.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.tripplanner.module.item.entity.TripItem;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface ItemMapper extends BaseMapper<TripItem> {
}
