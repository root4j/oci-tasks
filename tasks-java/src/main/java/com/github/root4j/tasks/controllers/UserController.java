package com.github.root4j.tasks.controllers;

import java.util.*;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import com.github.root4j.tasks.models.dtos.*;
import com.github.root4j.tasks.services.*;
import lombok.*;

@RestController
@RequestMapping("/api/users")
@CrossOrigin
@RequiredArgsConstructor
public class UserController {
    private final UserService service;

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public void create(@RequestBody UserRequest payload) {
        this.service.create(payload);
    }

    @GetMapping
    @ResponseStatus(HttpStatus.OK)
    public List<UserResponse> getAll() {
        return this.service.getAll();
    }
}