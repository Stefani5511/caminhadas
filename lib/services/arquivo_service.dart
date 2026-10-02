import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/caminhada.dart';

class ArquivoService {
  static Future<File> _arquivo() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/caminhadas.json');
  }

  static Future<List<Caminhada>> carregar() async {
    final file = await _arquivo();
    if (!await file.exists()) return [];
    try {
      final content = await file.readAsString();
      if (content.trim().isEmpty) return [];
      final data = jsonDecode(content) as List;
      return data.map((e) => Caminhada.fromJson(Map<String, dynamic>.from(e))).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> salvar(List<Caminhada> caminhadas) async {
    final file = await _arquivo();
    await file.writeAsString(jsonEncode(caminhadas.map((e) => e.toJson()).toList()));
  }
}
