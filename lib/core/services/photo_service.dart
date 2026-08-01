import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class PhotoService {
  PhotoService._();
  static final PhotoService instance = PhotoService._();
  static const _folder = 'homebox_photos';
  final _uuid = const Uuid();

  Future<String> get _photoDir async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, _folder));
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir.path;
  }

  Future<String?> persistPhoto(String sourcePath) async {
    try {
      final source = File(sourcePath);
      if (!await source.exists()) return null;
      return _writeBytes(await source.readAsBytes(), sourcePath);
    } catch (_) {
      return null;
    }
  }

  Future<String?> persistXFile(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) return null;
      final name = file.name.isNotEmpty ? file.name : file.path;
      return _writeBytes(bytes, name);
    } catch (_) {
      return null;
    }
  }

  Future<String?> persistBytes(Uint8List bytes, String name) async {
    if (bytes.isEmpty) return null;
    return _writeBytes(bytes, name);
  }

  Future<String?> persistPlatformFile(PlatformFile file) async {
    try {
      if (file.bytes != null && file.bytes!.isNotEmpty) {
        return _writeBytes(file.bytes!, file.name);
      }
      if (file.path != null) {
        return persistPhoto(file.path!);
      }
      if (file.readStream != null) {
        final chunks = <int>[];
        await for (final chunk in file.readStream!) {
          chunks.addAll(chunk);
        }
        if (chunks.isEmpty) return null;
        return _writeBytes(Uint8List.fromList(chunks), file.name);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<String?> _writeBytes(Uint8List bytes, String originalPath) async {
    try {
      var ext = p.extension(originalPath);
      if (ext.isEmpty || ext.length > 5) ext = '.jpg';
      final dest = p.join(await _photoDir, '${_uuid.v4()}$ext');
      await File(dest).writeAsBytes(bytes, flush: true);
      return dest;
    } catch (_) {
      return null;
    }
  }

  Future<void> deletePhoto(String path) async {
    try {
      final file = File(path);
      if (file.existsSync()) await file.delete();
    } catch (_) {}
  }

  Future<void> deletePhotos(Iterable<String> paths) async {
    for (final path in paths) {
      await deletePhoto(path);
    }
  }
}
