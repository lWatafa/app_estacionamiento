import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Conectamos con Supabase
  await Supabase.initialize(
    url: 'https://chaqdaiqpnyufyxvvuuc.supabase.co', // Tu URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNoYXFkYWlxcG55dWZ5eHZ2dXVjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTMzNDIwNTksImV4cCI6MjEwODkxODA1OX0._K1Xd0UOgTXnPKjeLSlKTNj01u8SUGeDrhfMJjlO2Bk', // <-- Pega la llave que copiaste
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Estacionamiento',
      home: LoginPage(),
    );
  }
}

// --- PANTALLA DE PRUEBA ---
class TestSupabasePage extends StatefulWidget {
  const TestSupabasePage({super.key});

  @override
  State<TestSupabasePage> createState() => _TestSupabasePageState();
}

class _TestSupabasePageState extends State<TestSupabasePage> {
  String _mensaje = 'Esperando para probar...';

  Future<void> _probarConexion() async {
    setState(() => _mensaje = 'Conectando...');
    try {
      // Intentamos leer algo de la tabla 'prueba' (o crearemos una)
      // Por ahora, solo haremos una consulta vacía para ver si responde
      final response = await Supabase.instance.client.from('usuarios').select();
      
      setState(() => _mensaje = '¡Conexión exitosa! Tabla usuarios existe. Filas: ${response.length}');
    } catch (e) {
      setState(() => _mensaje = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test de Supabase')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_mensaje, style: const TextStyle(fontSize: 18), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _probarConexion,
                child: const Text('Probar Conexión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}