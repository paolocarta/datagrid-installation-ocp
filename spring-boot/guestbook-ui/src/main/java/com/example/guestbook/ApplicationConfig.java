package com.example.guestbook;

import org.infinispan.client.hotrod.RemoteCacheManager;
import org.infinispan.spring.remote.provider.SpringRemoteCacheManager;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.cloud.client.circuitbreaker.EnableCircuitBreaker;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestTemplate;

@Configuration
@EnableCaching
@EnableCircuitBreaker
public class ApplicationConfig {

  private static final Logger logger = LoggerFactory.getLogger(ApplicationConfig.class);

  @Bean
  RestTemplate restTemplate() {
    RestTemplate restTemplate = new RestTemplate();
    return restTemplate;
  }

  @Bean
  public SpringRemoteCacheManager springRemoteCacheManager(RemoteCacheManager remoteCacheManager) {

    remoteCacheManager.administration().getOrCreateCache("demo-cache", "default");
    SpringRemoteCacheManager cacheManager = new SpringRemoteCacheManager(remoteCacheManager);

    return cacheManager;
  }


}
