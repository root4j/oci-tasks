package com.github.root4j.tasks.repositories;

import java.util.*;
import org.springframework.data.jpa.repository.*;
import org.springframework.stereotype.*;
import com.github.root4j.tasks.models.entities.*;

@Repository
public interface TaskRepository extends JpaRepository<Task, Long> {
    List<Task> findAllByUser_IdOrderByTitle(Long userId);
}