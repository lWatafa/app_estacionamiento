import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'user_model.dart';
import 'login_page.dart';

class AdminPage extends StatefulWidget {
  final String adminNombre;
  final String adminIdentificador;
  final String adminPlacas;

  const AdminPage({
    super.key, 
    required this.adminNombre,
    required this.adminIdentificador,
    required this.adminPlacas
  });

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  // Variable para saber qué pantalla mostrar en el cuerpo
  int _pantallaActual = 0; 

  // Controladores para el registro de usuarios
  final _nombreController = TextEditingController();
  final _identificadorController = TextEditingController();
  final _passwordController = TextEditingController();
  final _placasController = TextEditingController();
  final _licenciaController = TextEditingController();
  final _tarjetaController = TextEditingController();

  String _rolSeleccionado = 'estudiante';
  bool _cargando = false;

  Future<void> _crearUsuario() async {
    if (_nombreController.text.isEmpty || _identificadorController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nombre, identificador y contraseña son obligatorios.'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _cargando = true);

    try {
      final nuevoUsuario = Usuario(
        nombre: _nombreController.text.trim(),
        identificador: _identificadorController.text.trim(),
        password: _passwordController.text.trim(),
        rol: _rolSeleccionado,
        placas: _placasController.text.trim().isEmpty ? null : _placasController.text.trim().toUpperCase(),
        licencia: _licenciaController.text.trim().isEmpty ? null : _licenciaController.text.trim(),
        tarjetaCirculacion: _tarjetaController.text.trim().isEmpty ? null : _tarjetaController.text.trim(),
      );

      await Supabase.instance.client.from('usuarios').insert(nuevoUsuario.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Usuario creado exitosamente!'), backgroundColor: Colors.green),
        );
        _nombreController.clear();
        _identificadorController.clear();
        _passwordController.clear();
        _placasController.clear();
        _licenciaController.clear();
        _tarjetaController.clear();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Panel de Administrador'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      // --- DRAWER A LA DERECHA ---
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(widget.adminNombre),
              accountEmail: const Text('Administrador'),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.admin_panel_settings, size: 40, color: Colors.deepPurple),
              ),
              decoration: const BoxDecoration(color: Colors.deepPurple),
            ),
            ListTile(
              leading: const Icon(Icons.qr_code, color: Colors.deepPurple),
              title: const Text('Mi Código QR'),
              selected: _pantallaActual == 0,
              onTap: () {
                setState(() => _pantallaActual = 0);
                Navigator.pop(context); // Cierra el menú
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.deepPurple),
              title: const Text('Registros de Entrada/Salida'),
              selected: _pantallaActual == 1,
              onTap: () {
                setState(() => _pantallaActual = 1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add, color: Colors.deepPurple),
              title: const Text('Registrar Usuario'),
              selected: _pantallaActual == 2,
              onTap: () {
                setState(() => _pantallaActual = 2);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
              },
            ),
          ],
        ),
      ),
      // --- CUERPO DINÁMICO SEGÚN EL MENÚ ---
      body: _pantallaActual == 0 
          ? _construirMiQR() 
          : _pantallaActual == 1 
              ? _construirHistorial() 
              : _construirFormularioCreacion(),
    );
  }

  // ==========================================
  // 1. VISTA: MI CÓDIGO QR
  // ==========================================
  Widget _construirMiQR() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Mi Código de Acceso', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Muestra este código al guardia', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 24),
                QrImageView(
                  data: '${widget.adminIdentificador}-${widget.adminPlacas}',
                  version: QrVersions.auto,
                  size: 250.0,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 24),
                Text('Placas: ${widget.adminPlacas}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 2. VISTA: HISTORIAL GENERAL
  // ==========================================
  Widget _construirHistorial() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Supabase.instance.client
          .from('registros')
          .select('*, usuarios(nombre, rol)')
          .order('fecha', ascending: false),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));

        final registros = snapshot.data ?? [];
        if (registros.isEmpty) return const Center(child: Text('No hay registros aún.'));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: registros.length,
          itemBuilder: (context, index) {
            final reg = registros[index];
            final esEntrada = reg['tipo'] == 'entrada';
            final nombre = reg['usuarios']?['nombre'] ?? 'Desconocido';
            final rol = reg['usuarios']?['rol'] ?? 'N/A';
            
            DateTime fecha = DateTime.parse(reg['fecha']).toLocal();
            String fechaStr = "${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}";

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: esEntrada ? Colors.green.shade100 : Colors.red.shade100,
                  child: Icon(esEntrada ? Icons.login : Icons.logout, color: esEntrada ? Colors.green : Colors.red),
                ),
                title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${rol.toUpperCase()} - $fechaStr'),
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // 3. VISTA: FORMULARIO DE REGISTRO
  // ==========================================
  Widget _construirFormularioCreacion() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Text('Dar de Alta Nuevo Usuario', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Divider(height: 30),
              
              DropdownButtonFormField<String>(
                value: _rolSeleccionado,
                decoration: const InputDecoration(labelText: 'Rol del Usuario', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'estudiante', child: Text('Estudiante')),
                  DropdownMenuItem(value: 'docente', child: Text('Docente')),
                  DropdownMenuItem(value: 'empleado', child: Text('Empleado')),
                  DropdownMenuItem(value: 'guardia', child: Text('Guardia')),
                ],
                onChanged: (value) => setState(() => _rolSeleccionado = value!),
              ),
              const SizedBox(height: 16),

              TextField(controller: _nombreController, decoration: const InputDecoration(labelText: 'Nombre Completo', border: OutlineInputBorder())),
              const SizedBox(height: 16),

              TextField(
                controller: _identificadorController,
                decoration: InputDecoration(
                  labelText: _rolSeleccionado == 'estudiante' ? 'Número de Control' : 'Número de Empleado',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Contraseña asignada', border: OutlineInputBorder())),
              const SizedBox(height: 16),

              if (_rolSeleccionado == 'estudiante' || _rolSeleccionado == 'empleado') ...[
                TextField(controller: _licenciaController, decoration: const InputDecoration(labelText: 'Licencia de Conducir', border: OutlineInputBorder())),
                const SizedBox(height: 16),
                TextField(controller: _tarjetaController, decoration: const InputDecoration(labelText: 'Tarjeta de Circulación', border: OutlineInputBorder())),
                const SizedBox(height: 16),
              ],

              if (_rolSeleccionado != 'guardia')
                TextField(controller: _placasController, decoration: const InputDecoration(labelText: 'Placas del Vehículo', border: OutlineInputBorder())),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _cargando ? null : _crearUsuario,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: _cargando 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Guardar Usuario'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}