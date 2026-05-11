package com.tripplanner.module.photo.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.tripplanner.common.BusinessException;
import com.tripplanner.module.photo.dto.PhotoAlbumResp;
import com.tripplanner.module.photo.dto.PhotoResp;
import com.tripplanner.module.photo.entity.TripPhoto;
import com.tripplanner.module.photo.mapper.PhotoMapper;
import com.tripplanner.module.photo.service.PhotoService;
import com.tripplanner.module.trip.entity.Trip;
import com.tripplanner.module.trip.mapper.TripMapper;
import com.tripplanner.util.AliOssUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.*;
import java.util.stream.Collectors;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class PhotoServiceImpl implements PhotoService {

    private final PhotoMapper photoMapper;
    private final TripMapper tripMapper;
    private final AliOssUtil aliOssUtil;

    @Override
    public List<PhotoResp> list(Long userId, Long tripId, String location, String photoType, Boolean featured) {
        validateTripOwnership(userId, tripId);
        LambdaQueryWrapper<TripPhoto> wrapper = new LambdaQueryWrapper<TripPhoto>()
                .eq(TripPhoto::getTripId, tripId)
                .orderByDesc(TripPhoto::getSortOrder);
        if (location != null && !location.isBlank()) wrapper.eq(TripPhoto::getLocation, location);
        if (photoType != null && !photoType.isBlank()) wrapper.eq(TripPhoto::getPhotoType, photoType);
        if (featured != null && featured) wrapper.eq(TripPhoto::getIsFeatured, true);
        return photoMapper.selectList(wrapper).stream().map(this::toResp).toList();
    }

    @Override
    @Transactional
    public List<PhotoResp> uploadBatch(Long userId, Long tripId, String location, String photoType, MultipartFile[] files) {
        validateTripOwnership(userId, tripId);
        int maxSort = getMaxSort(tripId);
        List<PhotoResp> results = new ArrayList<>();

        for (int i = 0; i < files.length; i++) {
            MultipartFile file = files[i];
            if (file.isEmpty()) continue;
            try {
                String ext = getExtension(file.getOriginalFilename());
                String objectName = "photos/" + tripId + "/" + UUID.randomUUID() + ext;
                String url = aliOssUtil.upload(file.getBytes(), objectName);

                TripPhoto photo = new TripPhoto();
                photo.setTripId(tripId);
                photo.setUrl(url);
                photo.setLocation(location);
                photo.setPhotoType(photoType);
                photo.setIsFeatured(false);
                photo.setSortOrder(maxSort + i + 1);
                photoMapper.insert(photo);
                results.add(toResp(photo));
            } catch (IOException e) {
                throw new BusinessException("照片上传失败: " + file.getOriginalFilename());
            }
        }
        return results;
    }

    @Override
    @Transactional
    public List<PhotoResp> batchUpdate(Long userId, Long tripId, List<Long> ids, String location, String photoType, Boolean isFeatured) {
        validateTripOwnership(userId, tripId);
        List<PhotoResp> results = new ArrayList<>();
        for (Long id : ids) {
            TripPhoto photo = photoMapper.selectById(id);
            if (photo == null || !photo.getTripId().equals(tripId)) continue;
            if (location != null) photo.setLocation(location);
            if (photoType != null) photo.setPhotoType(photoType);
            if (isFeatured != null) photo.setIsFeatured(isFeatured);
            photoMapper.updateById(photo);
            results.add(toResp(photo));
        }
        return results;
    }

    @Override
    @Transactional
    public void batchDelete(Long userId, Long tripId, List<Long> ids) {
        validateTripOwnership(userId, tripId);
        for (Long id : ids) {
            TripPhoto photo = photoMapper.selectById(id);
            if (photo == null || !photo.getTripId().equals(tripId)) continue;
            photoMapper.deleteById(id);
        }
    }

    @Override
    @Transactional
    public void delete(Long userId, Long tripId, Long photoId) {
        TripPhoto photo = findAndValidate(userId, tripId, photoId);
        photoMapper.deleteById(photo.getId());
    }

    @Override
    @Transactional
    public PhotoResp toggleFeatured(Long userId, Long tripId, Long photoId) {
        TripPhoto photo = findAndValidate(userId, tripId, photoId);
        photo.setIsFeatured(!Boolean.TRUE.equals(photo.getIsFeatured()));
        photoMapper.updateById(photo);
        return toResp(photo);
    }

    @Override
    public List<PhotoAlbumResp> listAllPhotos(Long userId, int page, int size) {
        // Get all user trips, newest first
        List<Trip> trips = tripMapper.selectList(
                new LambdaQueryWrapper<Trip>()
                        .eq(Trip::getUserId, userId)
                        .orderByDesc(Trip::getStartDate));

        Map<Long, Trip> tripMap = new HashMap<>();
        List<Long> tripIds = new ArrayList<>();
        for (Trip t : trips) {
            tripMap.put(t.getId(), t);
            tripIds.add(t.getId());
        }

        if (tripIds.isEmpty()) return List.of();

        // Query photos for all user trips, ordered by creation time ascending
        List<TripPhoto> photos = photoMapper.selectList(
                new LambdaQueryWrapper<TripPhoto>()
                        .in(TripPhoto::getTripId, tripIds)
                        .orderByAsc(TripPhoto::getCreateTime));

        return photos.stream()
                .map(p -> {
                    Trip t = tripMap.get(p.getTripId());
                    PhotoAlbumResp resp = new PhotoAlbumResp();
                    BeanUtils.copyProperties(p, resp);
                    resp.setThumbnailUrl(p.getUrl() + "?x-oss-process=image/resize,w_400");
                    if (t != null) {
                        resp.setTripName(t.getTripName());
                        resp.setTripDestination(t.getDestination());
                        resp.setTripStartDate(t.getStartDate());
                    }
                    return resp;
                })
                .sorted(Comparator
                        .comparing(PhotoAlbumResp::getTripStartDate, Comparator.nullsLast(Comparator.reverseOrder()))
                        .thenComparing(PhotoAlbumResp::getCreateTime))
                .skip((long) (page - 1) * size)
                .limit(size)
                .collect(Collectors.toList());
    }

    private TripPhoto findAndValidate(Long userId, Long tripId, Long photoId) {
        TripPhoto photo = photoMapper.selectById(photoId);
        if (photo == null) throw BusinessException.notFound("照片不存在");
        if (!photo.getTripId().equals(tripId)) throw BusinessException.notFound("照片不属于该行程");
        validateTripOwnership(userId, tripId);
        return photo;
    }

    private void validateTripOwnership(Long userId, Long tripId) {
        Trip trip = tripMapper.selectById(tripId);
        if (trip == null || !trip.getUserId().equals(userId)) {
            throw BusinessException.forbidden("无权操作此行程");
        }
    }

    private int getMaxSort(Long tripId) {
        List<TripPhoto> list = photoMapper.selectList(
                new LambdaQueryWrapper<TripPhoto>()
                        .eq(TripPhoto::getTripId, tripId)
                        .orderByDesc(TripPhoto::getSortOrder)
                        .last("LIMIT 1"));
        return list.isEmpty() ? 0 : list.get(0).getSortOrder();
    }

    private String getExtension(String filename) {
        if (filename == null || !filename.contains(".")) return "";
        return filename.substring(filename.lastIndexOf("."));
    }

    private PhotoResp toResp(TripPhoto photo) {
        PhotoResp resp = new PhotoResp();
        BeanUtils.copyProperties(photo, resp);
        resp.setThumbnailUrl(photo.getUrl() + "?x-oss-process=image/resize,w_400");
        return resp;
    }
}
