import { Component, inject } from "@angular/core";
import { MatButtonModule } from "@angular/material/button";
import { MatCardModule } from "@angular/material/card";
import { MatDialog } from '@angular/material/dialog';
import { MatIconModule } from "@angular/material/icon";
import { MatMenuModule } from "@angular/material/menu";
import { MatTableModule } from "@angular/material/table";
import { Router } from "@angular/router";
import { User } from '../../api/api';
import { UserService } from '../../services/api.service';
import { UsersTasksComponent } from "../users-tasks/users-tasks.component";

@Component({
  selector: 'app-users',
  templateUrl: './users.component.html',
  styleUrl: './users.component.css',
  standalone: true,
  imports: [
    MatButtonModule,
    MatCardModule,
    MatIconModule,
    MatMenuModule,
    MatTableModule
  ]
})
export class UsersComponent {
  displayedColumns: string[] = ['id', 'firstName', 'lastName', 'email', 'task'];
  dataSource: User[] = [];

  usersService = inject(UserService);
  router = inject(Router);

  constructor(public dialog: MatDialog) {
    this.retrieveData();
  }

  add() {
    this.router.navigateByUrl('/users-form');
  }

  openTaskDialog(id: number) {
    this.dialog.open(UsersTasksComponent, {
      data: {
        userId: id,
      },
    });
  }
  
  retrieveData() {
    this.usersService.readAll().subscribe(data => {
      this.dataSource = data;
    });
  }
}
