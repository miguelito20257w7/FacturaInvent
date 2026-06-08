import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/shared_format/factura_json.dart';
import '../../l10n/app_localizations.dart';

class ImportDatabaseScreen extends ConsumerStatefulWidget {
  const ImportDatabaseScreen({super.key});

  @override
  ConsumerState<ImportDatabaseScreen> createState() =>
      _ImportDatabaseScreenState();
}

class _ImportDatabaseScreenState extends ConsumerState<ImportDatabaseScreen> {
  bool _busy = false;
  String? _status;
  bool _isError = false;
  bool _success = false;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _success
                    ? Icons.check_circle
                    : Icons.file_download_outlined,
                size: 56,
                color: _success
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 12),
              Text(
                _success ? t.importSuccessful : t.importDatabase,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (!_success)
                Text(
                  t.chooseJsonFile,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              const SizedBox(height: 16),
              if (_busy) const CircularProgressIndicator(),
              if (!_busy && !_success)
                FilledButton.icon(
                  onPressed: _importarJson,
                  icon: const Icon(Icons.file_download_outlined),
                  label: Text(t.importJson),
                ),
              if (_status != null) ...[
                const SizedBox(height: 12),
                Text(
                  _status!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _isError
                            ? Theme.of(context).colorScheme.error
                            : null,
                      ),
                ),
              ],
              if (!_success) ...[
                const SizedBox(height: 12),
                Text(
                  t.jsonRecommendation,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _busy ? null : () => Navigator.of(context).pop(),
                    child: Text(_success ? t.done : t.close),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmReplace() async {
    final t = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          icon: Icon(
            Icons.warning_amber_rounded,
            color: Theme.of(ctx).colorScheme.error,
            size: 40,
          ),
          title: Text(t.importConfirmTitle),
          content: Text(t.importConfirmBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(t.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error,
                foregroundColor: Theme.of(ctx).colorScheme.onError,
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(t.replaceAll),
            ),
          ],
        );
      },
    );
    return confirmed ?? false;
  }

  Future<void> _importarJson() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.single.path == null) return;
    if (!mounted) return;

    final confirmed = await _confirmReplace();
    if (!confirmed) return;
    if (!mounted) return;

    setState(() {
      _busy = true;
      _status = null;
      _isError = false;
      _success = false;
    });

    try {
      final file = File(result.files.single.path!);
      final json = await file.readAsString();

      final importer = ref.read(facturaJsonImporterProvider);
      final stats = await importer.importReplaceAll(json);
      if (!mounted) return;
      final t = AppLocalizations.of(context);
      setState(() {
        _busy = false;
        _success = true;
        _isError = false;
        _status = t.importedSummary(
          stats.empresasCreadas,
          stats.productosCreados,
        );
      });
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      final t = AppLocalizations.of(context);
      setState(() {
        _busy = false;
        _success = false;
        _status = '${t.error}: $e';
        _isError = true;
      });
    }
  }
}
