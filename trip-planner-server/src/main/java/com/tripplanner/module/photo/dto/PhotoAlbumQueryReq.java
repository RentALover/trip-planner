package com.tripplanner.module.photo.dto;

import lombok.Data;

@Data
public class PhotoAlbumQueryReq {
    private Integer page = 1;
    private Integer size = 30;
}
