import 'package:flutter/material.dart';

import '../api/api_client.dart';
import 'ajustes_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onLogin});
  final VoidCallback onLogin;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usuario = TextEditingController();
  final _password = TextEditingController();
  String? _error;
  bool _cargando = false;

  Future<void> _entrar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await APIClient.shared.login(_usuario.text.trim(), _password.text);
      widget.onLogin();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AjustesScreen()),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_pin, size: 70),
                const SizedBox(height: 16),
                Text('Iniciar sesión', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 24),
                TextField(
                  controller: _usuario,
                  decoration: const InputDecoration(
                      labelText: 'Usuario', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _password,
                  obscureText: true,
                  onSubmitted: (_) => _entrar(),
                  decoration: const InputDecoration(
                      labelText: 'Contraseña', border: OutlineInputBorder()),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _cargando ? null : _entrar,
                  child: _cargando
                      ? const SizedBox(
                          width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Entrar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
