import { Component, inject } from '@angular/core';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatSelectModule } from '@angular/material/select';
import { MatRadioModule } from '@angular/material/radio';
import { MatCardModule } from '@angular/material/card';
import { Router } from '@angular/router';
import { User, Task } from '../../api/api';
import { UserService, TaskService } from '../../services/api.service';

@Component({
  selector: 'app-tasks-form',
  templateUrl: './tasks-form.component.html',
  styleUrl: './tasks-form.component.css',
  standalone: true,
  imports: [
    MatInputModule,
    MatButtonModule,
    MatSelectModule,
    MatRadioModule,
    MatCardModule,
    ReactiveFormsModule
  ]
})
export class TasksFormComponent {
  private fb = inject(FormBuilder);
  usersService = inject(UserService);
  tasksService = inject(TaskService);
  router = inject(Router);

  users: User[] = [];

  taskForm = this.fb.group({
    company: null,
    title: ['', Validators.compose([Validators.required, Validators.minLength(3), Validators.maxLength(150)])],
    description: ['', Validators.compose([Validators.required, Validators.minLength(3), Validators.maxLength(512)])],
    userId: [0, Validators.required],
  });

  constructor() {
    this.retrieveData();
  }

  retrieveData() {
    this.usersService.readAll().subscribe(data => {
      this.users = data;
    });
  }

  saveData() {
    const task: Task = {
      title: this.taskForm.controls.title.value?.toString(),
      description: this.taskForm.controls.description.value?.toString(),
      done: false,
      userId: this.taskForm.controls.userId.value?.valueOf()
    };
    this.tasksService.create(task).subscribe(data => {
      this.router.navigateByUrl('/tasks');
    });
  }

  onSubmit(): void {
    if(!this.taskForm.invalid) {
      this.saveData();
    }
  }
}
