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
  bool _pagoActivo = false; 

  void _registrarUsuario() {
    if (_formKey.currentState!.validate()) {
      // Lógica pendiente
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
                      labelText: _rolSeleccionado == 'alumno' ? 'Número de Control' : _rolSeleccionado == 'externo' ? 'Número de INE' : 'Número de Empleado',
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

                  // --- SECCIÓN DE PAGO (Solo Alumnos) ---
                  if (_rolSeleccionado == 'alumno') ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber),
                      ),
                      child: Column(
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: Colors.orange),
                              SizedBox(width: 8),
                              Text('Cuota de Estacionamiento', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text('Como alumno, debes confirmar el pago de tu cuota semestral para poder registrar tu vehículo.'),
                          CheckboxListTile(
                            title: const Text('Confirmo que he pagado en caja'),
                            value: _pagoActivo,
                            activeColor: Colors.deepPurple,
                            onChanged: (value) => setState(() => _pagoActivo = value!),
                          ),
                        ],
                      ),
                    ),
                  ],

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
                      onPressed: _registrarUsuario,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Registrar Usuario', style: TextStyle(fontSize: 18)),
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