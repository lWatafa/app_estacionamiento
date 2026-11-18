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
              title: const Text('Inicio / Mi QR'),
              selected: _paginaSeleccionada == 0,
              onTap: () {
                setState(() => _paginaSeleccionada = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.deepPurple),
              title: const Text('Historial de Accesos'),
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
                Navigator.pushReplacement(
                  context, 
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
          ],
        ),
      ),

      body: _paginaSeleccionada == 0 ? _construirVistaPerfil() : _construirVistaHistorial(),
    );
  }

  // ==========================================
  // VISTA 1: PERFIL Y CÓDIGO QR
  // ==========================================
  Widget _construirVistaPerfil() {
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
                  onPressed: () => _marcarRegistro('entrada'),
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
                  onPressed: () => _marcarRegistro('salida'),
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
          
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Text('Código de Acceso Rápido', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Muestra este código en la entrada', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  
                  QrImageView(
                    data: '${widget.identificador}-${widget.placas}',
                    version: QrVersions.auto,
                    size: 200.0,
                    backgroundColor: Colors.white,
                  ),
                  
                  const SizedBox(height: 24),
                  const Text('Se regenera automáticamente cada 24 horas', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // VISTA 2: HISTORIAL REAL DESDE SUPABASE
  // ==========================================
  Widget _construirVistaHistorial() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Información del Usuario', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Divider(),
                  const SizedBox(height: 10),
                  _filaDato('Nombre:', widget.nombre),
                  _filaDato('Identificador:', widget.identificador),
                  _filaDato('Rol:', widget.rol.toUpperCase()),
                  _filaDato('Placas:', widget.placas),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),

          const Text('Historial de Entradas y Salidas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          
          // Usamos FutureBuilder para consultar Supabase
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: Supabase.instance.client
                  .from('registros')
                  .select()
                  .eq('usuario_id', widget.usuarioId)
                  .order('fecha', ascending: false), // El más reciente primero
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                final registros = snapshot.data ?? [];
                if (registros.isEmpty) {
                  return const Center(child: Text('No hay registros aún.'));
                }

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: registros.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final reg = registros[index];
                      bool esEntrada = reg['tipo'] == 'entrada';
                      
                      // Formatear la fecha (viene en formato ISO de Supabase)
                      DateTime fecha = DateTime.parse(reg['fecha']).toLocal();
                      String fechaStr = "${fecha.day}/${fecha.month}/${fecha.year} ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}";

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: esEntrada ? Colors.green.shade100 : Colors.red.shade100,
                          child: Icon(
                            esEntrada ? Icons.login : Icons.logout,
                            color: esEntrada ? Colors.green : Colors.red,
                          ),
                        ),
                        title: Text(esEntrada ? 'Entrada' : 'Salida', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(fechaStr),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Función para guardar entrada/salida en Supabase
  // Función para guardar entrada/salida en Supabase con validación
  Future<void> _marcarRegistro(String tipo) async {
    try {
      // 1. Consultamos el último registro del usuario
      final ultimoRegistro = await Supabase.instance.client
          .from('registros')
          .select('tipo')
          .eq('usuario_id', widget.usuarioId)
          .order('fecha', ascending: false) // El más reciente primero
          .limit(1)
          .maybeSingle();

      // 2. Lógica de validación
      if (ultimoRegistro != null) {
        if (ultimoRegistro['tipo'] == tipo) {
          // Si el último fue 'entrada' y quiere marcar 'entrada', o viceversa
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: Ya tienes una $tipo registrada. Debes marcar la ${tipo == 'entrada' ? 'salida' : 'entrada'} primero.'), 
                backgroundColor: Colors.orange,
              ),
            );
          }
          return; // Detenemos la ejecución aquí
        }
      } else {
        // Si no hay registros previos y quiere marcar 'salida', lo bloqueamos
        if (tipo == 'salida') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error: No puedes marcar salida sin haber entrado primero.'), 
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }
      }

      // 3. Si pasó las validaciones, guardamos el nuevo registro
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
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de conexión: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _filaDato(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(titulo, style: const TextStyle(color: Colors.grey)),
          Text(valor, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}