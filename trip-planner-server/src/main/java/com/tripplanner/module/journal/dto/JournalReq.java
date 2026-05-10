package com.tripplanner.module.journal.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class JournalReq {
    @NotBlank(message = "日记内容不能为空")
    private String content;
    private String mood;
    private String weather;
    private String imageUrls;
}
