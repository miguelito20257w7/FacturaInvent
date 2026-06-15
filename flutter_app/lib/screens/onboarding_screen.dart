import 'package:flutter/material.dart';

import '../api/server_config.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onListo});
  final VoidCallback onListo;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = TextEditingController(text: ServerConfig.shared.urlServidor);
  EstadoConexion get _estado => ServerConfig.shared.estado;

  Future<void> _probar() async {
    await ServerConfig.shared.guardar(url: _controller.text);
    setState(() {});
    await ServerConfig.shared.probarConexion();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.dns, size: 70),
                const SizedBox(height: 16),
                Text('Bienvenido a FacturaInvent 2',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                const Text(
                  'La app se conecta al servidor del supermercado. '
                  'Escribe su dirección en la red local.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: 'URL del servidor',
                    hintText: 'http://192.168.x.x:8000',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _probar,
                  icon: const Icon(Icons.wifi_tethering),
                  label: const Text('Probar conexión'),
                ),
                const SizedBox(height: 8),
                _IndicadorEstado(estado: _estado),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _estado == EstadoConexion.conectado
                      ? () async {
                          await ServerConfig.shared
                              .guardar(url: _controller.text, marcarConfigurado: true);
                          widget.onListo();
                        }
                      : null,
                  child: const Text('Continuar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IndicadorEstado extends StatelessWidget {
  const _IndicadorEstado({required this.estado});
  final EstadoConexion estado;

  @override
  Widget build(BuildContext context) {
    switch (estado) {
      case EstadoConexion.desconocido:
        return const SizedBox.shrink();
      case EstadoConexion.probando:
        return const SizedBox(
            width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2));
      case EstadoConexion.conectado:
        return const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.check_circle, color: Colors.green, size: 18),
          SizedBox(width: 6),
          Text('Conectado', style: TextStyle(color: Colors.green)),
        ]);
      case EstadoConexion.sinConexion:
        return const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.cancel, color: Colors.red, size: 18),
          SizedBox(width: 6),
          Text('Sin conexión', style: TextStyle(color: Colors.red)),
        ]);
    }
  }
}
