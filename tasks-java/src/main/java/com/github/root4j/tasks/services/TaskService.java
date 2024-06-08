package com.github.root4j.tasks.services;

import java.time.*;
import java.util.*;
import org.springframework.stereotype.*;
import com.github.root4j.tasks.models.dtos.*;
import com.github.root4j.tasks.models.entities.*;
import com.github.root4j.tasks.repositories.*;
import lombok.*;
import lombok.extern.slf4j.*;

@Service
@RequiredArgsConstructor
@Slf4j
public class TaskService {
    private final TaskRepository repository;
    private final UserRepository userRepo;

    public void create(TaskRequest request) {
        var user = userRepo.findById(request.getUserId());
        var entity = Task.builder()
                .user(user.get())
                .title(request.getTitle())
                .description(request.getDescription())
                .done(request.getDone())
                .createDate(LocalDateTime.now())
                .modifyDate(LocalDateTime.now())
                .build();
        repository.save(entity);
        log.info("Task added: {}", entity);
    }

    public void doneTask(Long taskId) {
        var taskTmp = repository.findById(taskId);
        if (taskTmp.isPresent()) {
            var entity = taskTmp.get();
            entity.setDone(true);
            repository.save(entity);
            log.info("Task updated: {}", entity);
        }
    }

    public List<TaskResponse> getAll() {
        var entities = repository.findAll();
        return entities.stream().map(this::mapToTaskResponse).toList();
    }

    public List<TaskResponse> getAllByUser(Long userId) {
        var entities = repository.findAllByUser_IdOrderByTitle(userId);
        return entities.stream().map(this::mapToTaskResponse).toList();
    }

    private TaskResponse mapToTaskResponse(Task entity) {
        return new TaskResponse(entity.getId(), entity.getTitle(), entity.getDescription(), entity.getDone(),
                entity.getUser().getId());
    }
}