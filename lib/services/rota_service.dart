import 'dart:convert';

import 'package:http/http.dart' as http;

class ResultadoRota {
  final double distanciaKm;
  final int tempoMin;
  final List<List<double>> pontos;

  ResultadoRota({required this.distanciaKm, required this.tempoMin, required this.pontos});
}

class RotaService {
  static Future<ResultadoRota> calcular({
    required double inicioLat,
    required double inicioLng,
    required double destinoLat,
    required double destinoLng,
  }) async {
    final uri = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/$inicioLng,$inicioLat;$destinoLng,$destinoLat?overview=full&geometries=geojson',
    );
    final response = await http.get(uri);
    if (response.statusCode != 200) throw Exception('Não foi possível calcular o trajeto.');

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final routes = json['routes'] as List;
    if (routes.isEmpty) throw Exception('Nenhum trajeto encontrado.');

    final route = Map<String, dynamic>.from(routes.first);
    final geometry = Map<String, dynamic>.from(route['geometry']);
    final coordinates = geometry['coordinates'] as List;
    final pontos = coordinates
        .map((p) => [(p[1] as num).toDouble(), (p[0] as num).toDouble()])
        .toList();

    final metros = (route['distance'] as num).toDouble();
    final segundos = (route['duration'] as num).toDouble();
    final distanciaKm = metros / 1000;
    final tempoMin = (distanciaKm / 5.0 * 60).ceil();

    return ResultadoRota(
      distanciaKm: distanciaKm,
      tempoMin: tempoMin > 0 ? tempoMin : (segundos / 60).round().clamp(1, 9999).toInt(),
      pontos: pontos,
    );
  }
}
