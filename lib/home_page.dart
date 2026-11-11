import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Variable para saber qué página mostrar (0 = Perfil, 1 = Historial)
  int _paginaSeleccionada = 0;

  // Datos simulados (luego los traeremos de Supabase)
  final String _nombreUsuario = 'Juan Pérez';
  final String _rolUsuario = 'alumno';
  final String _identificador = '241080496';
  final String _placas = 'ABC-123-A';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Panel Principal',
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF7A1C31),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          
            const Icon(
              Icons.local_parking, 
              size: 100, 
              color: Color(0xFF7A1C31),
            ),
            const SizedBox(height: 20),
            const Text(
              'Bienvenido al Estacionamiento',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.login),
              label: const Text('Marcar Entrada'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
                backgroundColor: const Color(0xFF7A1C31), 
                foregroundColor: Colors.white, 
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout),
              label: const Text('Marcar Salida'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
                backgroundColor: const Color(0xFF4A4A4A),
                foregroundColor: Colors.white,
              ),
=======
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(_paginaSeleccionada == 0 ? 'Mi Perfil' : 'Mi Historial'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      
      // --- BARRA LATERAL (DRAWER) ---
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text('Usuario ITIZ', style: TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: Text('Estacionamiento'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.deepPurple),
              ),
              decoration: BoxDecoration(color: Colors.deepPurple),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.deepPurple),
              title: const Text('Inicio / Mi QR'),
              selected: _paginaSeleccionada == 0,
              onTap: () {
                setState(() => _paginaSeleccionada = 0);
                Navigator.pop(context); // Cierra el menú
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
                // 1. Cerramos el menú lateral
                Navigator.pop(context); 
                
                // 2. Reemplazamos la pantalla actual con el Login
                Navigator.pushReplacement(
                  context, 
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
>>>>>>> d7bdb0418bec1fc63d0fa81bc74ee27224b3afc9
            ),
          ],
        ),
      ),

      // --- CUERPO DINÁMICO ---
      // Aquí se decide si mostramos la vista de Perfil o de Historial
      body: _paginaSeleccionada == 0 ? _construirVistaPerfil() : _construirVistaHistorial(),
    );
  }

  // ==========================================
  // VISTA 1: PERFIL Y CÓDIGO QR
  // ==========================================
  Widget _construirVistaPerfil() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Tarjeta del Perfil
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
                  Text(_nombreUsuario, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text('Rol: ${_rolUsuario.toUpperCase()}', style: const TextStyle(color: Colors.grey, fontSize: 16)),
                  const Divider(height: 30),
                  
                  // Datos breves
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          const Text('Identificación', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text(_identificador, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(width: 40),
                      Column(
                        children: [
                          const Text('Placas', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          Text(_placas, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Tarjeta del Código QR
          Expanded(
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Código de Acceso Rápido', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Muestra este código en la entrada', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 24),
                    
                    // Generador de QR
                    QrImageView(
                      data: '$_identificador-$_placas', // Datos que contiene el QR
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
          ),
        ],
      ),
    );
  }

  // ==========================================
  // VISTA 2: HISTORIAL Y DATOS COMPLETOS
  // ==========================================
  Widget _construirVistaHistorial() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tarjeta de Datos Completos
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
                  _filaDato('Nombre:', _nombreUsuario),
                  _filaDato('Identificador:', _identificador),
                  _filaDato('Rol:', _rolUsuario.toUpperCase()),
                  _filaDato('Vehículo:', 'Nissan Versa (Rojo)'), // Simulado
                  _filaDato('Placas:', _placas),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),

          // Lista de Registros
          const Text('Historial de Entradas y Salidas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Expanded(
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: 4, // Simulamos 4 registros
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  // Datos simulados para la lista
                  bool esEntrada = index % 2 == 0;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: esEntrada ? Colors.green.shade100 : Colors.red.shade100,
                      child: Icon(
                        esEntrada ? Icons.login : Icons.logout,
                        color: esEntrada ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text(esEntrada ? 'Entrada' : 'Salida', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Hoy, ${10 - index}:30 AM'),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget de ayuda para crear las filas de datos
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
