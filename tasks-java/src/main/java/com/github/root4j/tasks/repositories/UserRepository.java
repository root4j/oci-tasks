package com.github.root4j.tasks.repositories;

import org.springframework.data.jpa.repository.*;
import org.springframework.stereotype.*;
import com.github.root4j.tasks.models.entities.*;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
}