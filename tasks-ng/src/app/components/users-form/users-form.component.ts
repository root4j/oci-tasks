import { Component, inject } from '@angular/core';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatSelectModule } from '@angular/material/select';
import { MatRadioModule } from '@angular/material/radio';
import { MatCardModule } from '@angular/material/card';
import { Router } from '@angular/router';
import { User } from '../../api/api';
import { UserService } from '../../services/api.service';

@Component({
  selector: 'app-users-form',
  templateUrl: './users-form.component.html',
  styleUrl: './users-form.component.css',
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
export class UsersFormComponent {
  private fb = inject(FormBuilder);
  usersService = inject(UserService);
  router = inject(Router);

  usersForm = this.fb.group({
    firstName: ['', Validators.required],
    lastName: ['', Validators.required],
    email: ['', [Validators.required, Validators.email]],
  });

  saveData() {
    const user: User = {
      firstName: this.usersForm.controls.firstName.value?.toString(),
      lastName: this.usersForm.controls.lastName.value?.toString(),
      email: this.usersForm.controls.email.value?.toString()
    };
    this.usersService.create(user).subscribe(data => {
      this.router.navigateByUrl('/users');
    });
  }

  onSubmit(): void {
    if(!this.usersForm.invalid) {
      this.saveData();
    }
  }
}
