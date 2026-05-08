package com.tripplanner.module.trip.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.tripplanner.module.trip.entity.Trip;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface TripMapper extends BaseMapper<Trip> {
}
