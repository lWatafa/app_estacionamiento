import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  final String nombre;
  final String rol;
  final String identificador;
  final String placas;
  final String usuarioId;

  const HomePage({
    super.key,
    required this.nombre,
    required this.rol,
    required this.identificador,
    required this.placas,
    required this.usuarioId,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _paginaSeleccionada = 0;

  // --- FUNCIÓN PARA MARCAR ENTRADA O SALIDA ---
  Future<void> _marcarAcceso(String tipo) async {
    try {
      // 1. Verificamos cuál fue el último movimiento para evitar dobles registros
      final ultimoReg = await Supabase.instance.client
          .from('registros')
          .select('tipo')
          .eq('usuario_id', widget.usuarioId)
          .order('fecha', ascending: false)
          .limit(1)
          .maybeSingle();

      if (ultimoReg != null && ultimoReg['tipo'] == tipo) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: Ya tienes una $tipo registrada. Debes marcar la ${tipo == 'entrada' ? 'salida' : 'entrada'} primero.'), 
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      if (ultimoReg == null && tipo == 'salida') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: No puedes salir sin haber entrado.'), backgroundColor: Colors.orange),
          );
        }
        return;
      }

      // 2. Guardamos el registro en Supabase
      await Supabase.instance.client.from('registros').insert({
        'usuario_id': widget.usuarioId,
        'tipo': tipo,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡$tipo registrada con éxito!'), 
            backgroundColor: tipo == 'entrada' ? Colors.green : Colors.red,
          ),
        );
        // Refrescamos la pantalla para que el historial se actualice
        setState(() {
          _paginaSeleccionada = 1; 
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(_paginaSeleccionada == 0 ? 'Mi Perfil' : 'Mi Historial'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(widget.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: Text(widget.rol.toUpperCase()),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.deepPurple),
              ),
              decoration: const BoxDecoration(color: Colors.deepPurple),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.deepPurple),
              title: const Text('Mi Perfil y QR'),
              selected: _paginaSeleccionada == 0,
              onTap: () {
                setState(() => _paginaSeleccionada = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.deepPurple),
              title: const Text('Mi Historial'),
              selected: _paginaSeleccionada == 1,
              onTap: () {
                setState(() => _paginaSeleccionada = 1);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context); 
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
              },
            ),
          ],
        ),
      ),
      body: _paginaSeleccionada == 0 ? _construirVistaPerfil() : _construirVistaHistorial(),
    );
  }

  // ==========================================
  // VISTA 1: PERFIL (Depende del Rol)
  // ==========================================
  Widget _construirVistaPerfil() {
    // 1. SI ES EXTERNO: Mostrar solo su Pase de Visitante (sin botones)
    if (widget.rol == 'externo') {
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
                  const Icon(Icons.badge, size: 80, color: Colors.orange),
                  const SizedBox(height: 16),
                  const Text('Pase de Visitante', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(widget.nombre, style: const TextStyle(fontSize: 18, color: Colors.grey)),
                  const Divider(height: 40),
                  QrImageView(
                    data: '${widget.identificador}-${widget.placas}',
                    version: QrVersions.auto,
                    size: 220.0,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Muestra este código al guardia para registrar tu entrada o salida.', 
                    textAlign: TextAlign.center, 
                    style: TextStyle(color: Colors.grey)
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // 2. SI NO ES EXTERNO (Estudiantes, docentes, admins): Mostrar vista normal
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.deepPurple,
                    child: Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(widget.nombre, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text('Rol: ${widget.rol.toUpperCase()}', style: const TextStyle(color: Colors.grey, fontSize: 16)),
                  const Divider(height: 30),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          const Text('Identificación', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text(widget.identificador, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(width: 40),
                      Column(
                        children: [
                          const Text('Placas', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text(widget.placas, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),

          // --- BOTONES DE ENTRADA Y SALIDA ---
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _marcarAcceso('entrada'),
                  icon: const Icon(Icons.login),
                  label: const Text('Entrada'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _marcarAcceso('salida'),
                  icon: const Icon(Icons.logout),
                  label: const Text('Salida'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Tarjeta del Código QR
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Text('Código de Acceso Rápido', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Muestra este código al guardia', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  
                  QrImageView(
                    data: '${widget.identificador}-${widget.placas}',
                    version: QrVersions.auto,
                    size: 200.0,
                    backgroundColor: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // VISTA 2: HISTORIAL DEL USUARIO
  // ==========================================
  Widget _construirVistaHistorial() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Mi Historial de Accesos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: Supabase.instance.client
                  .from('registros')
                  .select()
                  .eq('usuario_id', widget.usuarioId)
                  .order('fecha', ascending: false),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                
                final registros = snapshot.data ?? [];
                if (registros.isEmpty) return const Center(child: Text('No tienes registros aún.'));

                return ListView.builder(
                  itemCount: registros.length,
                  itemBuilder: (context, index) {
                    final reg = registros[index];
                    bool esEntrada = reg['tipo'] == 'entrada';
                    
                    DateTime fecha = DateTime.parse(reg['fecha']).toLocal();
                    String fechaStr = "${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}";

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: esEntrada ? Colors.green.shade100 : Colors.red.shade100,
                          child: Icon(
                            esEntrada ? Icons.login : Icons.logout,
                            color: esEntrada ? Colors.green : Colors.red,
                          ),
                        ),
                        title: Text(esEntrada ? 'Entrada' : 'Salida', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(fechaStr),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}