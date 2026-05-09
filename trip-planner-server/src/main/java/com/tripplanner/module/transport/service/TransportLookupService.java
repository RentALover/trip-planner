package com.tripplanner.module.transport.service;

import com.tripplanner.module.transport.dto.TransportLookupResult;

import java.time.LocalDate;

public interface TransportLookupService {
    TransportLookupResult lookup(String type, String number, LocalDate date);
}
