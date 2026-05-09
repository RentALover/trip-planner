package com.tripplanner.util;

import com.aliyun.oss.OSS;
import com.aliyun.oss.OSSClientBuilder;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.extern.slf4j.Slf4j;

import java.io.ByteArrayInputStream;

@Data
@AllArgsConstructor
@Slf4j
public class AliOssUtil {

    private String endpoint;
    private String accessKeyId;
    private String accessKeySecret;
    private String bucketName;

    public String upload(byte[] bytes, String objectName) {
        OSS ossClient = new OSSClientBuilder().build(endpoint, accessKeyId, accessKeySecret);
        try {
            ossClient.putObject(bucketName, objectName, new ByteArrayInputStream(bytes));
        } finally {
            ossClient.shutdown();
        }

        String url = "https://" + bucketName + "." + endpoint + "/" + objectName;
        log.info("File uploaded to: {}", url);
        return url;
    }
}
