import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';

class GuardiaPage extends StatefulWidget {
  final String guardiaNombre;
  const GuardiaPage({super.key, required this.guardiaNombre});

  @override
  State<GuardiaPage> createState() => _GuardiaPageState();
}

class _GuardiaPageState extends State<GuardiaPage> {
  int _pantallaActual = 0;
  
  // Controlador para el escáner (simulado)
  final _qrController = TextEditingController();
  bool _procesando = false;

  // Variable para el filtro del historial
  String _filtroRol = 'todos';

  // --- LÓGICA PARA PROCESAR EL QR ---
  Future<void> _procesarQR() async {
    String codigo = _qrController.text.trim();
    if (codigo.isEmpty) return;

    setState(() => _procesando = true);
    _qrController.clear();

    try {
      // El código viene en formato: "identificador-placas"
      List<String> partes = codigo.split('-');
      if (partes.length < 2) {
        throw Exception("Formato de QR inválido. Debe ser ID-PLACAS");
      }
      
      String identificador = partes[0];
      String placas = partes.sublist(1).join('-'); // Por si las placas tienen guiones

      // 1. Buscar al usuario en Supabase
      final usuarioResp = await Supabase.instance.client
          .from('usuarios')
          .select()
          .eq('identificador', identificador)
          .eq('placas', placas)
          .maybeSingle();

      if (usuarioResp == null) {
        throw Exception("Vehículo no registrado en el sistema.");
      }

      String usuarioId = usuarioResp['id'];
      String nombre = usuarioResp['nombre'];

      // 2. Consultar su último movimiento para ver si entra o sale
      final ultimoReg = await Supabase.instance.client
          .from('registros')
          .select('tipo')
          .eq('usuario_id', usuarioId)
          .order('fecha', ascending: false)
          .limit(1)
          .maybeSingle();

      String nuevoTipo = 'entrada';
      if (ultimoReg != null && ultimoReg['tipo'] == 'entrada') {
        nuevoTipo = 'salida'; // Si ya estaba dentro, ahora sale
      }

      // 3. Registrar el movimiento
      await Supabase.instance.client.from('registros').insert({
        'usuario_id': usuarioId,
        'tipo': nuevoTipo,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$nombre registró una $nuevoTipo'), 
            backgroundColor: nuevoTipo == 'entrada' ? Colors.green : Colors.red,
          ),
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.orange),
        );
      }
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Panel de Guardia'),
        backgroundColor: Colors.blueGrey[800],
        foregroundColor: Colors.white,
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(widget.guardiaNombre),
              accountEmail: const Text('Seguridad / Guardia'),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.security, size: 40, color: Colors.blueGrey),
              ),
              decoration: BoxDecoration(color: Colors.blueGrey[800]),
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_scanner, color: Colors.blueGrey),
              title: const Text('Escanear QR'),
              selected: _pantallaActual == 0,
              onTap: () {
                setState(() => _pantallaActual = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt, color: Colors.blueGrey),
              title: const Text('Registro de Movimientos'),
              selected: _pantallaActual == 1,
              onTap: () {
                setState(() => _pantallaActual = 1);
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
      body: _pantallaActual == 0 ? _construirEscaner() : _construirHistorialFiltrado(),
    );
  }

  // --- VISTA 1: ESCÁNER QR (SIMULADO) ---
  Widget _construirEscaner() {
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
                const Icon(Icons.qr_code_scanner, size: 100, color: Colors.blueGrey),
                const SizedBox(height: 16),
                const Text('Escáner de Acceso', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Pega el código del QR o usa la cámara', style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                
                TextField(
                  controller: _qrController,
                  decoration: const InputDecoration(
                    labelText: 'Código del QR',
                    hintText: 'Ej. admin-ADMIN-01',
                    prefixIcon: Icon(Icons.keyboard),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                
                _procesando 
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _procesarQR,
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Validar Acceso'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.blueGrey[800],
                        foregroundColor: Colors.white,
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- VISTA 2: HISTORIAL CON FILTROS ---
  Widget _construirHistorialFiltrado() {
    return Column(
      children: [
        // Barra de filtros
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Text('Filtrar por: ', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _filtroRol,
                  decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'todos', child: Text('Todos')),
                    DropdownMenuItem(value: 'estudiante', child: Text('Estudiantes')),
                    DropdownMenuItem(value: 'docente', child: Text('Docentes')),
                    DropdownMenuItem(value: 'empleado', child: Text('Empleados')),
                    DropdownMenuItem(value: 'externo', child: Text('Externos')),
                    DropdownMenuItem(value: 'admin', child: Text('Administrativos')),
                  ],
                  onChanged: (value) {
                    setState(() => _filtroRol = value!);
                  },
                ),
              ),
            ],
          ),
        ),
        
        // Lista de registros
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _filtroRol == 'todos'
                ? Supabase.instance.client.from('registros').select('*, usuarios(nombre, rol)').order('fecha', ascending: false)
                : Supabase.instance.client.from('registros').select('*, usuarios!inner(nombre, rol)').eq('usuarios.rol', _filtroRol).order('fecha', ascending: false),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
              if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));

              final registros = snapshot.data ?? [];
              if (registros.isEmpty) return const Center(child: Text('No hay registros para este filtro.'));

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: registros.length,
                itemBuilder: (context, index) {
                  final reg = registros[index];
                  final esEntrada = reg['tipo'] == 'entrada';
                  final nombre = reg['usuarios']?['nombre'] ?? 'Desconocido';
                  final rol = reg['usuarios']?['rol'] ?? 'N/A';
                  
                  DateTime fecha = DateTime.parse(reg['fecha']).toLocal();
                  String fechaStr = "${fecha.day}/${fecha.month} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}";

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
          ),
        ),
      ],
    );
  }
}