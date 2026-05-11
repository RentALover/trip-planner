package com.tripplanner.module.export.controller;

import com.tripplanner.common.Result;
import com.tripplanner.module.export.service.ExportService;
import com.tripplanner.util.UserContextHolder;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.nio.charset.StandardCharsets;

@RestController
@RequestMapping("/api/v1/trips/{tripId}/export")
@RequiredArgsConstructor
public class ExportController {

    private final ExportService exportService;

    @GetMapping("/text")
    public ResponseEntity<byte[]> exportText(@PathVariable Long tripId) {
        String text = exportService.exportText(UserContextHolder.getUserId(), tripId);
        byte[] bytes = text.getBytes(StandardCharsets.UTF_8);

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION,
                        "attachment; filename=trip-" + tripId + ".md")
                .contentType(MediaType.TEXT_PLAIN)
                .body(bytes);
    }

    @GetMapping("/json")
    public Result<String> exportJson(@PathVariable Long tripId) {
        return Result.success(exportService.exportJson(UserContextHolder.getUserId(), tripId));
    }
}
