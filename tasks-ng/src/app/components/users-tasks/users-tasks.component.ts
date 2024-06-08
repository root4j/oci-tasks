import { Component, inject, Inject } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import {
    MAT_DIALOG_DATA,
    MatDialogActions,
    MatDialogClose,
    MatDialogContent,
    MatDialogTitle,
} from '@angular/material/dialog';
import { MatCardModule } from "@angular/material/card";
import { MatIconModule } from "@angular/material/icon";
import { MatTableModule } from "@angular/material/table";
import { Task } from "../../api/api";
import { TaskService } from "../../services/api.service";

export interface UserTaskData {
    userId: number;
}

@Component({
    selector: 'app-users-tasks',
    templateUrl: './users-tasks.component.html',
    standalone: true,
    imports: [
        MatDialogTitle,
        MatDialogContent,
        MatDialogActions,
        MatDialogClose,
        MatButtonModule,
        MatCardModule,
        MatIconModule,
        MatTableModule
    ],
})
export class UsersTasksComponent {
    displayedColumns: string[] = ['title', 'done'];
    dataSource: Task[] = [];

    tasksService = inject(TaskService);

    constructor(@Inject(MAT_DIALOG_DATA) public dataDialog: UserTaskData) {
        this.retrieveData(dataDialog.userId);
    }

    updateData(id: number) {
        this.tasksService.update(id, {}).subscribe(data => {
            this.retrieveData(this.dataDialog.userId);
        });
    }

    retrieveData(id: number) {
        this.tasksService.readAllByUser(id).subscribe(data => {
            this.dataSource = data;
        });
    }
}