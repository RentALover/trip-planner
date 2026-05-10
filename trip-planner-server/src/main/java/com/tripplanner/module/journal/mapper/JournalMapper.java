package com.tripplanner.module.journal.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.tripplanner.module.journal.entity.DayJournal;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface JournalMapper extends BaseMapper<DayJournal> {
}
