package com.tripplanner.module.transport.controller;

import com.tripplanner.common.Result;
import com.tripplanner.module.transport.dto.TransportLookupResult;
import com.tripplanner.module.transport.service.TransportLookupService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;

@RestController
@RequestMapping("/api/v1/transport-lookup")
@RequiredArgsConstructor
public class TransportLookupController {

    private final TransportLookupService transportLookupService;

    @GetMapping
    public Result<TransportLookupResult> lookup(
            @RequestParam String type,
            @RequestParam String number,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        TransportLookupResult result = transportLookupService.lookup(type, number, date);
        return Result.success(result);
    }
}
