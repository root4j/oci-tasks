package com.github.root4j.tasks.controllers;

import java.util.*;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import com.github.root4j.tasks.models.dtos.*;
import com.github.root4j.tasks.services.*;
import lombok.*;

@RestController
@RequestMapping("/api/tasks")
@CrossOrigin
@RequiredArgsConstructor
public class TaskController {
    private final TaskService service;

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public void create(@RequestBody TaskRequest payload) {
        this.service.create(payload);
    }

    @CrossOrigin
    @PutMapping("/{id}")
    @ResponseStatus(HttpStatus.ACCEPTED)
    public void update(@PathVariable long id) {
        this.service.doneTask(id);
    }

    @GetMapping
    @ResponseStatus(HttpStatus.OK)
    public List<TaskResponse> getAll() {
        return this.service.getAll();
    }

    @CrossOrigin
    @GetMapping("/user/{id}")
    @ResponseStatus(HttpStatus.OK)
    public List<TaskResponse> getAllByUser(@PathVariable long id) {
        return this.service.getAllByUser(id);
    }
}