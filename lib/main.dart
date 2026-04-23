import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:parcial_2/routes/app_router.dart';

Future<void> main() async {
  // Asegura que los bindings de Flutter estén listos antes de ejecutar código asíncrono
  WidgetsFlutterBinding.ensureInitialized();
  
  // Carga segura del archivo .env
  try {
    await dotenv.load(fileName: ".env");
    print("✅ Variables de entorno cargadas");
  } catch (e) {
    print("⚠️ Error cargando el archivo .env: $e");
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Parcial Flutter 2',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple, // Un color sobrio para el parcial
      ),
      routerConfig: appRouter,
    );
  }
}