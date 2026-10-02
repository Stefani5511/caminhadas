class Caminhada {
  final String id;
  final String titulo;
  final double inicioLat;
  final double inicioLng;
  final double destinoLat;
  final double destinoLng;
  final double distanciaKm;
  final int tempoMin;
  final double calorias;
  final List<List<double>> rota;
  final String? fotoPath;
  final String data;

  Caminhada({
    required this.id,
    required this.titulo,
    required this.inicioLat,
    required this.inicioLng,
    required this.destinoLat,
    required this.destinoLng,
    required this.distanciaKm,
    required this.tempoMin,
    required this.calorias,
    required this.rota,
    required this.data,
    this.fotoPath,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'inicioLat': inicioLat,
        'inicioLng': inicioLng,
        'destinoLat': destinoLat,
        'destinoLng': destinoLng,
        'distanciaKm': distanciaKm,
        'tempoMin': tempoMin,
        'calorias': calorias,
        'rota': rota,
        'fotoPath': fotoPath,
        'data': data,
      };

  factory Caminhada.fromJson(Map<String, dynamic> json) => Caminhada(
        id: json['id'] as String,
        titulo: json['titulo'] as String,
        inicioLat: (json['inicioLat'] as num).toDouble(),
        inicioLng: (json['inicioLng'] as num).toDouble(),
        destinoLat: (json['destinoLat'] as num).toDouble(),
        destinoLng: (json['destinoLng'] as num).toDouble(),
        distanciaKm: (json['distanciaKm'] as num).toDouble(),
        tempoMin: (json['tempoMin'] as num).toInt(),
        calorias: (json['calorias'] as num).toDouble(),
        rota: (json['rota'] as List)
            .map((p) => (p as List).map((v) => (v as num).toDouble()).toList())
            .toList(),
        fotoPath: json['fotoPath'] as String?,
        data: json['data'] as String,
      );
}
