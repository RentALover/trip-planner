package com.tripplanner.module.photo.controller;

import com.tripplanner.common.PageResult;
import com.tripplanner.common.Result;
import com.tripplanner.module.photo.dto.PhotoAlbumQueryReq;
import com.tripplanner.module.photo.dto.PhotoAlbumResp;
import com.tripplanner.module.photo.service.PhotoService;
import com.tripplanner.util.UserContextHolder;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/photos")
@RequiredArgsConstructor
public class PhotoAlbumController {

    private final PhotoService photoService;

    @GetMapping
    public Result<List<PhotoAlbumResp>> listAll(@RequestParam(defaultValue = "1") int page,
                                                 @RequestParam(defaultValue = "30") int size) {
        return Result.success(photoService.listAllPhotos(UserContextHolder.getUserId(), page, size));
    }
}
