import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../api/server_config.dart';

class AjustesScreen extends StatefulWidget {
  const AjustesScreen({super.key});

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  final _controller = TextEditingController(text: ServerConfig.shared.urlServidor);

  Future<void> _probar() async {
    await ServerConfig.shared.guardar(url: _controller.text);
    setState(() {});
    await ServerConfig.shared.probarConexion();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final estado = ServerConfig.shared.estado;
    final usuario = APIClient.shared.usuarioActual;

    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Servidor', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'URL del servidor',
              hintText: 'http://192.168.x.x:8000',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _probar(),
          ),
          const SizedBox(height: 8),
          Row(children: [
            OutlinedButton.icon(
              onPressed: _probar,
              icon: const Icon(Icons.wifi_tethering),
              label: const Text('Probar conexión'),
            ),
            const SizedBox(width: 12),
            if (estado == EstadoConexion.probando)
              const SizedBox(
                  width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
            else if (estado == EstadoConexion.conectado)
              const Text('● Conectado', style: TextStyle(color: Colors.green))
            else if (estado == EstadoConexion.sinConexion)
              const Text('● Sin conexión', style: TextStyle(color: Colors.red)),
          ]),
          const SizedBox(height: 4),
          const Text(
            'El cambio aplica de inmediato, sin reiniciar la app.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const Divider(height: 32),
          Text('Sesión', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (usuario != null) ...[
            Text('Usuario: ${usuario.nombre} (${usuario.rol})'),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                await APIClient.shared.logout();
                if (context.mounted) Navigator.of(context).pop();
              },
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar sesión'),
            ),
          ] else
            const Text('Sin sesión activa'),
        ],
      ),
    );
  }
}
