package com.tripplanner.module.day.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.tripplanner.module.day.entity.TripDay;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface DayMapper extends BaseMapper<TripDay> {
}
