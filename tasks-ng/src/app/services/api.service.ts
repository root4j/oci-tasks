import { HttpClient } from "@angular/common/http";
import { Injectable } from "@angular/core";
import { Observable } from "rxjs";
import { User, Task } from "../api/api";
import { Crud } from "./core.service";

@Injectable({
    providedIn: 'root'
})
export class UserService extends Crud<User> {
    constructor(protected override http: HttpClient) {
        super(http, 'api/users');
    }
}

@Injectable({
    providedIn: 'root'
})
export class TaskService extends Crud<Task> {
    constructor(protected override http: HttpClient) {
        super(http, 'api/tasks');
    }

    readAllByUser(id: number): Observable<Task[]> {
        var url = `${this.apiUrl}/user/${id}`;
        return this.http.get<Task[]>(url);
    }
}