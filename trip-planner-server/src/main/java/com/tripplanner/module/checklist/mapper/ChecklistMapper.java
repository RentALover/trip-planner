package com.tripplanner.module.checklist.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.tripplanner.module.checklist.entity.ChecklistItem;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface ChecklistMapper extends BaseMapper<ChecklistItem> {
}
