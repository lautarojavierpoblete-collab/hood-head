
import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

export interface EstadoApi {
  estado: string;
  proyecto: string;
  mensaje: string;
}

@Injectable({
  providedIn: 'root',
})
export class ApiService {
  private readonly http = inject(HttpClient);

  private readonly apiUrl = 'http://localhost:5014/api/health';

  obtenerEstado(): Observable<EstadoApi> {
    return this.http.get<EstadoApi>(this.apiUrl);
  }
}
