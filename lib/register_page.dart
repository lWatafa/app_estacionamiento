import 'package:flutter/material.dart';

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

  // Aquí luego irá la conexión a Supabase
  void _registrarUsuario() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos guardados'), backgroundColor: Color.fromARGB(255, 63, 238, 77)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de Usuario')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre Completo', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Ingresa tu nombre' : null,
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
                validator: (value) => value!.isEmpty ? 'Este campo es obligatorio' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder()),
                validator: (value) => value!.length < 4 ? 'Mínimo 4 caracteres' : null,
              ),
              const SizedBox(height: 16),

              // --- DATOS DEL COCHE ---
              const Text('Datos del Vehículo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _placasController,
                decoration: const InputDecoration(labelText: 'Placas del Vehículo', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Ingresa las placas' : null,
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _registrarUsuario,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Registrarse'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}