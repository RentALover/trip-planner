package com.tripplanner.module.export.service;

public interface ExportService {
    String exportText(Long userId, Long tripId);
    String exportJson(Long userId, Long tripId);
}
