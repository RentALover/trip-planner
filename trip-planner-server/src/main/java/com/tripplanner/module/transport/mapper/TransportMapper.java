package com.tripplanner.module.transport.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.tripplanner.module.transport.entity.ItemTransport;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface TransportMapper extends BaseMapper<ItemTransport> {
}
