package com.github.root4j.tasks.models.dtos;

public record TaskResponse(Long id, String title, String description, Boolean done, Long userId) {}