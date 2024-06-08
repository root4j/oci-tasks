package com.github.root4j.tasks.models.dtos;

import lombok.*;

@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class TaskRequest {
    private Long id;
    private String title;
    private String description;
    private Boolean done;
    private Long userId;
}