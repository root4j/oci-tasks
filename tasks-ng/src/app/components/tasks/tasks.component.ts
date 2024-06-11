import { Component, inject } from "@angular/core";
import { MatButtonModule } from "@angular/material/button";
import { MatCardModule } from "@angular/material/card";
import { MatIconModule } from "@angular/material/icon";
import { MatMenuModule } from "@angular/material/menu";
import { MatTableModule } from "@angular/material/table";
import { Router } from "@angular/router";
import { Task } from "../../api/api";
import { TaskService } from "../../services/api.service";

@Component({
  selector: 'app-tasks',
  templateUrl: './tasks.component.html',
  styleUrl: './tasks.component.css',
  standalone: true,
  imports: [
    MatButtonModule,
    MatCardModule,
    MatIconModule,
    MatMenuModule,
    MatTableModule
  ]
})
export class TasksComponent {
  displayedColumns: string[] = ['id', 'title', 'done'];
  dataSource: Task[] = [];

  tasksService = inject(TaskService);
  router = inject(Router);

  constructor() {
    this.retrieveData();
  }

  add() {
    this.router.navigateByUrl('/tasks-form');
  }

  retrieveData() {
    this.tasksService.readAll().subscribe(data => {
      this.dataSource = data;
    });
  }
}
