import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'register_page.dart';
import 'home_page.dart';
import 'admin_page.dart'; // <-- IMPORTANTE: Importamos el nuevo panel de admin
import 'guardia_page.dart'; // <-- IMPORTANTE: Importamos el nuevo panel de guardia
import 'register_externo_page.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false; // Para mostrar el círculo de carga

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    String usuario = _userController.text.trim();
    String password = _passwordController.text.trim();

    if (usuario.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Llena todos los campos'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Buscamos al usuario en Supabase
      final response = await Supabase.instance.client
          .from('usuarios')
          .select()
          .eq('identificador', usuario)
          .maybeSingle();

      if (response != null) {
        // 2. Validamos contraseña
        if (response['password'] == password) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('¡Bienvenido ${response['nombre']}!'), backgroundColor: Colors.green),
            );
            
            // 3. Verificamos el rol para redirigir al panel correcto
            if (response['rol'] == 'admin') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminPage(
                      adminNombre: response['nombre'],
                      adminIdentificador: response['identificador'],
                      adminPlacas: response['placas'] ?? 'ADMIN-01',
                    ),
                  ), 
                );
              } else if (response['rol'] == 'guardia') { // <-- NUEVO BLOQUE
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GuardiaPage(guardiaNombre: response['nombre']),
                  ),
                );
              }else {
              // Si es estudiante, docente, empleado o externo, va al HomePage normal
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(
                    nombre: response['nombre'],
                    rol: response['rol'],
                    identificador: response['identificador'],
                    placas: response['placas'] ?? 'Sin placas',
                    usuarioId: response['id'],
                  ),
                ),
              );
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Contraseña incorrecta'), backgroundColor: Colors.red),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario no encontrado'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_parking, size: 100, color: Colors.deepPurple),
                  const SizedBox(height: 16),
                  const Text(
                    'Estacionamiento ITIZ',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                  const SizedBox(height: 32),
                  
                  TextField(
                    controller: _userController,
                    decoration: InputDecoration(
                      labelText: 'Identificador',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 19, 41, 243),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Ingresar', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                    const SizedBox(height: 16),
                  
                  // Único botón de registro para gente del exterior
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => const RegisterExternoPage())
                      );
                    },
                    child: const Text(
                      'Soy Visitante / Gente del Exterior', 
                      style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}