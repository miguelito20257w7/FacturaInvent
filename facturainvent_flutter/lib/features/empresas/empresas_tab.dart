import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/firestore/empresa_repository.dart';
import '../../data/shared_format/factura_json.dart';
import '../../l10n/app_localizations.dart';
import '../../models/empresa.dart';
import '../shared/import_database_screen.dart';
import 'empresa_detalle.dart';

class EmpresasTab extends ConsumerWidget {
  const EmpresasTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final empresasAsync = ref.watch(empresasStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.tabBusinesses),
        leading: IconButton(
          icon: const Icon(Icons.file_download_outlined),
          tooltip: t.importDatabase,
          onPressed: () {
            showDialog<void>(
              context: context,
              builder: (_) => const ImportDatabaseScreen(),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share),
            tooltip: t.shareJson,
            onPressed: () async {
              await _exportarJson(context, ref);
            },
          ),
        ],
      ),
      body: empresasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (empresas) {
          if (empresas.isEmpty) {
            return _ContentUnavailable(
              icon: Icons.business,
              title: t.noBusinesses,
              description: t.addBusinessToStart,
            );
          }
          return ListView.separated(
            itemCount: empresas.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final empresa = empresas[i];
              return _EmpresaTile(empresa: empresa);
            },
          );
        },
      ),
    );
  }

  Future<void> _exportarJson(BuildContext context, WidgetRef ref) async {
    final t = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final exporter = ref.read(facturaJsonExporterProvider);
      final dir = await getApplicationDocumentsDirectory();
      final fecha = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final file = File('${dir.path}/facturainvent-$fecha.json');
      await exporter.exportToFile(file);
      if (!context.mounted) return;
      final result = await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'facturainvent-$fecha.json',
      );
      if (!context.mounted) return;
      if (result.status == ShareResultStatus.success) {
        messenger.showSnackBar(
          SnackBar(content: Text(t.jsonSharedSuccess)),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('${t.error}: $e')),
      );
    }
  }
}

class _EmpresaTile extends ConsumerWidget {
  final Empresa empresa;
  const _EmpresaTile({required this.empresa});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    return ListTile(
      title: Text(empresa.nombre),
      trailing: Text(t.nitColon(empresa.nit)),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => EmpresaDetalle(empresa: empresa)),
        );
      },
    );
  }
}

class _ContentUnavailable extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _ContentUnavailable({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
