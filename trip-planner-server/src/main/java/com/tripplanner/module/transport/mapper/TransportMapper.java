package com.tripplanner.module.transport.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.tripplanner.module.transport.entity.ItemTransport;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface TransportMapper extends BaseMapper<ItemTransport> {

    @Delete("DELETE FROM item_transport WHERE day_id = #{dayId}")
    void hardDeleteByDayId(@Param("dayId") Long dayId);
}
