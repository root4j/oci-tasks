import { Routes } from "@angular/router";
import { DashboardComponent } from "./components/dashboard/dashboard.component";
import { TasksComponent } from "./components/tasks/tasks.component";
import { TasksFormComponent } from "./components/tasks-form/tasks-form.component";
import { UsersComponent } from "./components/users/users.component";
import { UsersFormComponent } from "./components/users-form/users-form.component";

export const routes: Routes = [
    {path: '', component: DashboardComponent},
    {path: 'users', component: UsersComponent},
    {path: 'users-form', component: UsersFormComponent},
    {path: 'tasks', component: TasksComponent},
    {path: 'tasks-form', component: TasksFormComponent}
];