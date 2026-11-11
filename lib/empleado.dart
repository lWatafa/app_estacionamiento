import 'package:flutter/material.dart';

class EmpleadoPage extends StatefulWidget {
  const EmpleadoPage({super.key});

  @override
  State<EmpleadoPage> createState() => _EmpleadoPageState();
}

class _EmpleadoPageState extends State<EmpleadoPage> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  
  // Número de empleado institucional
  final String numeroEmpleado = "ITIZ-2026-094";

  void _registrarVisitante() {
    final nombre = _nombreController.text;
    final telefono = _telefonoController.text;

    if (nombre.isEmpty || telefono.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, completa todos los campos obligatorios'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Registro Exitoso'),
        content: Text('Visitante: $nombre\nNúmero: $telefono\nRegistrado por: $numeroEmpleado'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _nombreController.clear();
              _telefonoController.clear();
            },
            child: const Text('Aceptar', style: TextStyle(color: Color(0xFF7A1C31))),
          ),
        ],
      ),
    );
  }

  void _tomarFotoCarro() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Abriendo cámara para capturar foto del carro...'),
        backgroundColor: Color(0xFF4A4A4A),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fondo blanco idéntico al Home
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Módulo de Empleado',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        // Mismo color guinda institucional del ITIZ
        backgroundColor: const Color(0xFF7A1C31), 
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tarjeta superior estilizada con el color del ITIZ
            Card(
              color: const Color(0xFF7A1C31).withOpacity(0.08),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFF7A1C31), width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.badge, color: Color(0xFF7A1C31), size: 40),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Empleado Activo',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        Text(
                          'No. $numeroEmpleado',
                          style: const TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold, 
                            color: Color(0xFF7A1C31),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            const Text(
              'Registrar Nuevo Visitante',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Campos de texto enfocados en color guinda
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre Completo del Visitante',
                prefixIcon: Icon(Icons.person, color: Color(0xFF7A1C31)),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF7A1C31), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _telefonoController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Número de Teléfono / Celular',
                prefixIcon: Icon(Icons.phone, color: Color(0xFF7A1C31)),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF7A1C31), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Botón para la captura del auto con bordes guinda
            OutlinedButton.icon(
              onPressed: _tomarFotoCarro,
              icon: const Icon(Icons.directions_car),
              label: const Text('Capturar Foto del Carro'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: const Color(0xFF7A1C31),
                side: const BorderSide(color: Color(0xFF7A1C31)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 35),

            // Botón de Registrar en color Guinda ITIZ
            ElevatedButton.icon(
              onPressed: _registrarVisitante,
              icon: const Icon(Icons.how_to_reg),
              label: const Text('Registrar Entrada'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: const Color(0xFF7A1C31), 
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }
}
