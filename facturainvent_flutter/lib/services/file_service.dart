import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';
import 'package:share_plus/share_plus.dart';

class FileService {
  Future<File?> pickXmlFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xml'],
    );
    final path = result?.files.single.path;
    return path == null ? null : File(path);
  }

  Future<File?> pickJsonFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    final path = result?.files.single.path;
    return path == null ? null : File(path);
  }

  Future<void> shareFile(File file, {String? subject}) async {
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: subject,
    );
  }

  /// En desktop conviene "guardar como…" en vez del share sheet.
  Future<String?> saveFileAs(File file, {required String suggestedName}) async {
    final location = await getSaveLocation(suggestedName: suggestedName);
    if (location == null) return null;
    final bytes = await file.readAsBytes();
    final out = File(location.path);
    await out.writeAsBytes(bytes);
    return out.path;
  }
}
