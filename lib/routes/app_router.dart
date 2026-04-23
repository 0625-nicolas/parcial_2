import 'package:go_router/go_router.dart';

// Importaciones de las vistas (se pondrán rojas por ahora, no te preocupes)
import 'package:parcial_2/views/dashboard_view.dart';
import 'package:parcial_2/views/estadisticas_view.dart';
import 'package:parcial_2/views/establecimientos_list_view.dart';
import 'package:parcial_2/views/establecimiento_form_view.dart';
import 'package:parcial_2/models/establecimiento_model.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // 1. Dashboard (Home)
    GoRoute(
      path: '/',
      builder: (context, state) => const DashboardView(),
    ),
    
    // 2. Estadísticas de Accidentes
    GoRoute(
      path: '/estadisticas',
      builder: (context, state) => const EstadisticasView(),
    ),
    
    // 3. Listado de Establecimientos
    GoRoute(
      path: '/establecimientos',
      builder: (context, state) => const EstablecimientosListView(),
    ),
    
    // 4. Crear Establecimiento
    GoRoute(
      path: '/establecimientos/crear',
      builder: (context, state) => const EstablecimientoFormView(),
    ),

    // 5. Editar Establecimiento (Recibe el modelo completo como 'extra')
    GoRoute(
      path: '/establecimientos/editar',
      builder: (context, state) {
        final establecimiento = state.extra as EstablecimientoModel;
        return EstablecimientoFormView(establecimiento: establecimiento);
      },
    ),
  ],
);