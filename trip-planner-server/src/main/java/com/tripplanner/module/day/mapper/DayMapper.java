package com.tripplanner.module.day.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.tripplanner.module.day.entity.TripDay;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface DayMapper extends BaseMapper<TripDay> {

    @Delete("DELETE FROM trip_day WHERE trip_id = #{tripId}")
    void hardDeleteByTripId(@Param("tripId") Long tripId);
}
