package com.tripplanner.module.photo.service;

import com.tripplanner.module.photo.dto.PhotoResp;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface PhotoService {
    List<PhotoResp> list(Long userId, Long tripId, String location, String photoType, Boolean featured);
    List<PhotoResp> uploadBatch(Long userId, Long tripId, String location, String photoType, MultipartFile[] files);
    List<PhotoResp> batchUpdate(Long userId, Long tripId, List<Long> ids, String location, String photoType, Boolean isFeatured);
    void batchDelete(Long userId, Long tripId, List<Long> ids);
    void delete(Long userId, Long tripId, Long photoId);
    PhotoResp toggleFeatured(Long userId, Long tripId, Long photoId);
    List<com.tripplanner.module.photo.dto.PhotoAlbumResp> listAllPhotos(Long userId, int page, int size);
}
