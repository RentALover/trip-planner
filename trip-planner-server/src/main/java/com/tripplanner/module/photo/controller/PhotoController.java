package com.tripplanner.module.photo.controller;

import com.tripplanner.common.Result;
import com.tripplanner.module.photo.dto.BatchDeleteReq;
import com.tripplanner.module.photo.dto.PhotoBatchUpdateReq;
import com.tripplanner.module.photo.dto.PhotoResp;
import com.tripplanner.module.photo.service.PhotoService;
import com.tripplanner.util.UserContextHolder;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/api/v1/trips/{tripId}/photos")
@RequiredArgsConstructor
public class PhotoController {

    private final PhotoService photoService;

    @GetMapping
    public Result<List<PhotoResp>> list(@PathVariable Long tripId,
                                         @RequestParam(required = false) String location,
                                         @RequestParam(required = false) String photoType,
                                         @RequestParam(required = false, defaultValue = "false") Boolean featured) {
        return Result.success(photoService.list(UserContextHolder.getUserId(), tripId, location, photoType, featured));
    }

    @PostMapping("/batch")
    public Result<List<PhotoResp>> uploadBatch(@PathVariable Long tripId,
                                                @RequestParam(required = false) String location,
                                                @RequestParam(required = false) String photoType,
                                                @RequestParam("files") MultipartFile[] files) {
        return Result.success(photoService.uploadBatch(UserContextHolder.getUserId(), tripId, location, photoType, files));
    }

    @PutMapping("/batch")
    public Result<List<PhotoResp>> batchUpdate(@PathVariable Long tripId,
                                                @RequestBody PhotoBatchUpdateReq req) {
        return Result.success(photoService.batchUpdate(UserContextHolder.getUserId(), tripId,
                req.getIds(), req.getLocation(), req.getPhotoType(), req.getIsFeatured()));
    }

    @DeleteMapping("/batch")
    public Result<Void> batchDelete(@PathVariable Long tripId, @RequestBody BatchDeleteReq req) {
        photoService.batchDelete(UserContextHolder.getUserId(), tripId, req.getIds());
        return Result.success();
    }

    @DeleteMapping("/{photoId}")
    public Result<Void> delete(@PathVariable Long tripId, @PathVariable Long photoId) {
        photoService.delete(UserContextHolder.getUserId(), tripId, photoId);
        return Result.success();
    }

    @PatchMapping("/{photoId}/featured")
    public Result<PhotoResp> toggleFeatured(@PathVariable Long tripId, @PathVariable Long photoId) {
        return Result.success(photoService.toggleFeatured(UserContextHolder.getUserId(), tripId, photoId));
    }
}
