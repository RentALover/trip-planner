package com.tripplanner.module.item.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.tripplanner.module.item.entity.TripItem;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface ItemMapper extends BaseMapper<TripItem> {

    @Delete("DELETE FROM trip_item WHERE day_id = #{dayId}")
    void hardDeleteByDayId(@Param("dayId") Long dayId);
}
