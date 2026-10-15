
import { Component, OnInit, signal, inject } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { ApiService, EstadoApi } from './services/api.service';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet],
  templateUrl: './app.html',
  styleUrl: './app.scss',
})
export class App implements OnInit {
  private readonly apiService = inject(ApiService);

  protected readonly title = signal('HOOD HEAD');
  protected readonly estado = signal('Conectando con el backend...');
  protected readonly conectado = signal(false);

  ngOnInit(): void {
    this.apiService.obtenerEstado().subscribe({
      next: (respuesta: EstadoApi) => {
        this.estado.set(respuesta.mensaje);
        this.conectado.set(true);
      },
      error: (error) => {
        console.error('Error al conectar con el backend:', error);
        this.estado.set('No se pudo conectar con el backend.');
        this.conectado.set(false);
      },
    });
  }
}
