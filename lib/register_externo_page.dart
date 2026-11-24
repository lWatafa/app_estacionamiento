import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_model.dart';

class RegisterExternoPage extends StatefulWidget {
  const RegisterExternoPage({super.key});

  @override
  State<RegisterExternoPage> createState() => _RegisterExternoPageState();
}

class _RegisterExternoPageState extends State<RegisterExternoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _ineController = TextEditingController();
  final _passwordController = TextEditingController();
  final _placasController = TextEditingController();
  final _motivoController = TextEditingController();
  
  bool _cargando = false;

  Future<void> _registrarExterno() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _cargando = true);

      try {
        // Creamos el usuario con el rol 'externo'
        final nuevoUsuario = Usuario(
          nombre: _nombreController.text.trim(),
          identificador: _ineController.text.trim(), // El INE es su identificador
          password: _passwordController.text.trim(),
          rol: 'externo',
          placas: _placasController.text.trim().toUpperCase(),
          motivo: _motivoController.text.trim(),
        );

        // Insertamos en Supabase
        await Supabase.instance.client.from('usuarios').insert(nuevoUsuario.toMap());

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('¡Registro exitoso! Ya puedes iniciar sesión.'), backgroundColor: Colors.green),
          );
          Navigator.pop(context); // Regresa al Login
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _cargando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Visitantes'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text('Registro de Gente del Exterior', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Divider(height: 30),
                  
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(labelText: 'Nombre Completo', border: OutlineInputBorder()),
                    validator: (value) => value!.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _ineController,
                    decoration: const InputDecoration(labelText: 'Número de INE', border: OutlineInputBorder()),
                    validator: (value) => value!.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Contraseña para consultar', border: OutlineInputBorder()),
                    validator: (value) => value!.length < 4 ? 'Mínimo 4 caracteres' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _placasController,
                    decoration: const InputDecoration(labelText: 'Placas del Vehículo', border: OutlineInputBorder()),
                    validator: (value) => value!.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _motivoController,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Motivo de la visita', border: OutlineInputBorder()),
                    validator: (value) => value!.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: _cargando ? null : _registrarExterno,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                    child: _cargando 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Registrarme y Obtener Pase'),
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