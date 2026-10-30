import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel Principal')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.local_parking, size: 100, color: Colors.deepPurple),
            const SizedBox(height: 20),
            const Text('Bienvenido al Estacionamiento', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.login),
              label: const Text('Marcar Entrada'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout),
              label: const Text('Marcar Salida'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50), backgroundColor: Colors.red, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}