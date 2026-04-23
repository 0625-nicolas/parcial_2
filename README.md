# Parcial Flutter — Accidentes Tuluá + CRUD Establecimientos

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![UCEVA](https://img.shields.io/badge/UCEVA-Sistemas-green?style=for-the-badge)

## Información del Desarrollador
* **Nombre:** Nicolas Gutierrez Escudero
* **Institución:** Unidad Central del Valle del Cauca (UCEVA)
* **Programa:** Ingeniería de Sistemas
* **Asignatura:** Electiva Moviles
* **Fecha:** Abril, 2026

---

## Descripción del Proyecto
Aplicación móvil de alto rendimiento que integra la analítica de **100,000 registros** de accidentalidad vial en Tuluá con un sistema administrativo (CRUD) híbrido para establecimientos comerciales. La aplicación está diseñada para ser resiliente a fallos de backend y optimizada para el procesamiento de datos masivos.

---

## Fuentes de Datos y APIs

### 1. API de Accidentalidad (Open Data)
* **Fuente:** Portal de Datos Abiertos de Colombia.
* **Endpoint:** `https://www.datos.gov.co/resource/66v9-v5p7.json`
* **Campos Relevantes:**
    * `clase_accidente`: Tipo de incidente (Choque, Atropello, Caída ocupante).
    * `gravedad`: Impacto (Muertos, Heridos, Solo daños).
    * `barrio`: Ubicación para análisis geográfico.
    * `fecha`: Timestamp para determinar tendencias temporales.

### 2. API de Establecimientos (Gestión Administrativa)
* **Fuente:** Backend Laravel (UCEVA).
* **Endpoints:**
    * `GET /establecimientos`: Obtención de registros.
    * `POST /establecimientos`: Creación.
    * `POST /establecimiento-update/{id}`: Actualización (vía Method Spoofing).
    * `DELETE /establecimientos/{id}`: Eliminación.
* **Campos Relevantes:** `nombre`, `nit`, `direccion`, `telefono`, `logo`.

---

## Decisiones Técnicas: Concurrencia y Rendimiento

### Future (async/await) vs. Isolate
En este proyecto se implementó una diferenciación crítica según la carga computacional:

| Tecnología | Aplicación | Justificación Técnica |
| :--- | :--- | :--- |
| **Future / Async** | Peticiones HTTP y SharedPreferences. | Ideal para tareas de I/O donde el procesador está en espera. |
| **Isolate (compute)** | Procesamiento de 100k registros de accidentes. | Las tareas CPU-Intensive bloquean el **Event Loop** (UI Thread). Se delegó el cálculo estadístico a un Isolate nativo para mantener los 60 FPS en la interfaz. |

---

## Arquitectura y Estructura
El proyecto sigue una organización modular para garantizar escalabilidad:

* **`lib/models/`**: Clases de datos y serialización JSON.
* **`lib/services/`**: Capa de red (Dio) y persistencia híbrida (SharedPreferences).
* **`lib/isolates/`**: Lógica de procesamiento en segundo plano.
* **`lib/views/`**: Pantallas (Dashboard, Estadísticas, CRUD).
* **`lib/routes/`**: Configuración declarativa con `go_router`.

---

## Rutas y Navegación (GoRouter)

| Ruta | Pantalla | Parámetros Enviados |
| :--- | :--- | :--- |
| `/dashboard` | Menú Principal | N/A |
| `/estadisticas` | Analítica de Datos | N/A |
| `/establecimientos` | Listado de Locales | N/A |
| `/establecimientos/crear` | Formulario Crear | N/A |
| `/establecimientos/editar` | Formulario Editar | `extra: EstablecimientoModel` |

---

## Capturas de pantalla

<table style="width: 100%; text-align: center;">
  <tr>
    <td><img src="https://github.com/user-attachments/assets/312a9feb-73a4-4f60-873f-bb38f41fc63f" width="200"></td>
    <td><img src="https://github.com/user-attachments/assets/f0aa2ae3-62bf-49be-b957-0d88e63a3d31" width="200"></td>
    <td><img src="https://github.com/user-attachments/assets/b5c12634-52ed-4e4c-b61f-8d05d779a4f1" width="200"></td>
    <td><img src="https://github.com/user-attachments/assets/4293ce62-9d56-4bf7-bfb5-d24894bec75b" width="200"></td>
  </tr>
  <tr>
    <td><img src="https://github.com/user-attachments/assets/ab12bb83-aaf9-4c16-aadd-dea5991b059f" width="200"></td>
    <td><img src="https://github.com/user-attachments/assets/e842aab7-753e-4b92-bbd8-63fcfb691dc7" width="200"></td>
    <td><img src="https://github.com/user-attachments/assets/8705aa35-5812-4be9-9dc2-08bb2778d064" width="200"></td>
    <td><img src="https://github.com/user-attachments/assets/5344799a-0150-4abc-bfbd-58bb3a2764e8" width="200"></td>
  </tr>
</table>

## Ejemplos de Respuesta JSON

### Accidentes
```json
{
  "clase_accidente": "Choque",
  "gravedad": "Con Heridos",
  "barrio": "Victoria",
  "fecha": "2024-04-22T00:00:00.000"
}
{
  "id": 105,
  "nombre": "Establecimiento Nicolas",
  "nit": "123456789-0",
  "direccion": "Calle 25 # 12-10",
  "telefono": "3151234567",
  "logo": "null"
}
