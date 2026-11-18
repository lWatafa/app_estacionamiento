import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  
  final _nombreController = TextEditingController();
  final _identificadorController = TextEditingController();
  final _passwordController = TextEditingController();
  final _placasController = TextEditingController();
  
  String _rolSeleccionado = 'alumno';
  bool _cargando = false; // Variable para el círculo de carga

  // Función conectada a Supabase
  Future<void> _registrarUsuario() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _cargando = true);

      try {
        // Guardamos en la tabla 'usuarios' de Supabase
        await Supabase.instance.client.from('usuarios').insert({
          'nombre': _nombreController.text.trim(),
          'identificador': _identificadorController.text.trim(),
          'password': _passwordController.text.trim(),
          'rol': _rolSeleccionado,
          'placas': _placasController.text.trim().toUpperCase(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('¡Usuario registrado con éxito!'), backgroundColor: Colors.green),
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
        title: const Text('Crear Cuenta'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[100],
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
                  const Text('Datos Personales', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Divider(),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(labelText: 'Nombre Completo', border: OutlineInputBorder()),
                    validator: (value) => value!.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<String>(
                    value: _rolSeleccionado,
                    decoration: const InputDecoration(labelText: 'Rol', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'alumno', child: Text('Alumno')),
                      DropdownMenuItem(value: 'docente', child: Text('Docente')),
                      DropdownMenuItem(value: 'administrativo', child: Text('Administrativo')),
                      DropdownMenuItem(value: 'empleado', child: Text('Empleado')),
                      DropdownMenuItem(value: 'externo', child: Text('Gente del Exterior')),
                    ],
                    onChanged: (value) => setState(() => _rolSeleccionado = value!),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _identificadorController,
                    decoration: InputDecoration(
                      labelText: _rolSeleccionado == 'alumno' 
                          ? 'Número de Control' 
                          : _rolSeleccionado == 'externo' 
                              ? 'Número de INE' 
                              : 'Número de Empleado',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) => value!.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder()),
                    validator: (value) => value!.length < 4 ? 'Mínimo 4 caracteres' : null,
                  ),

                  // NOTA: La sección de pago para alumnos fue eliminada.

                  const SizedBox(height: 24),
                  const Text('Datos del Vehículo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Divider(),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _placasController,
                    decoration: const InputDecoration(labelText: 'Placas del Vehículo', border: OutlineInputBorder()),
                    validator: (value) => value!.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _cargando ? null : _registrarUsuario,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _cargando
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Registrar Usuario', style: TextStyle(fontSize: 18)),
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