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
public class UserService {
    private final UserRepository repository;

    public void create(UserRequest request) {
        var entity = User.builder()
                .firstName(request.getFirstName())
                .lastName(request.getLastName())
                .email(request.getEmail())
                .createDate(LocalDateTime.now())
                .modifyDate(LocalDateTime.now())
                .build();
        repository.save(entity);
        log.info("User added: {}", entity);
    }

    public List<UserResponse> getAll() {
        var entities = repository.findAll();
        return entities.stream().map(this::mapToUserResponse).toList();
    }

    private UserResponse mapToUserResponse(User entity) {
        return new UserResponse(entity.getId(), entity.getFirstName(), entity.getLastName(), entity.getEmail());
    }
}