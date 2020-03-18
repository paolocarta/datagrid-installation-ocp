
package com.example.guestbook;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloworldUiController {

  private final static Logger logger = LoggerFactory.getLogger(HelloworldUiController.class);

  @GetMapping("/")
  public String index() {

//    logger.info("Inside get index method");


    return "";
  }

  @PostMapping("/greet")
  public String greet(
      @RequestParam String name, 
      @RequestParam String message) {


    return "";
  }
}
