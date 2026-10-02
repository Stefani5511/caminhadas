import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';

import '../models/caminhada.dart';

class DetalhesCaminhada extends StatefulWidget {
  final Caminhada caminhada;
  const DetalhesCaminhada({super.key, required this.caminhada});
  @override State<DetalhesCaminhada> createState() => _DetalhesCaminhadaState();
}

class _DetalhesCaminhadaState extends State<DetalhesCaminhada> {
  late Caminhada caminhada;
  final picker = ImagePicker();

  @override void initState() { super.initState(); caminhada = widget.caminhada; }

  Future<void> tirarFoto() async {
    final image = await picker.pickImage(source: ImageSource.camera, imageQuality: 82);
    if (image == null) return;
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/caminhada_${caminhada.id}.jpg';
    await File(image.path).copy(path);
    setState(() => caminhada = Caminhada(id: caminhada.id, titulo: caminhada.titulo, inicioLat: caminhada.inicioLat, inicioLng: caminhada.inicioLng, destinoLat: caminhada.destinoLat, destinoLng: caminhada.destinoLng, distanciaKm: caminhada.distanciaKm, tempoMin: caminhada.tempoMin, calorias: caminhada.calorias, rota: caminhada.rota, data: caminhada.data, fotoPath: path));
  }

  @override Widget build(BuildContext context) {
    final inicio = LatLng(caminhada.inicioLat, caminhada.inicioLng);
    final destino = LatLng(caminhada.destinoLat, caminhada.destinoLng);
    final pontos = caminhada.rota.map((p) => LatLng(p[0], p[1])).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes da caminhada')),
      body: ListView(padding: const EdgeInsets.all(12), children: [
        Card(clipBehavior: Clip.antiAlias, child: SizedBox(height: 280, child: FlutterMap(options: MapOptions(initialCenter: destino, initialZoom: 15), children: [TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'br.senai.caminhadas'), PolylineLayer(polylines: [Polyline(points: pontos, strokeWidth: 5, color: Theme.of(context).colorScheme.primary)]), MarkerLayer(markers: [Marker(point: inicio, width: 44, height: 44, child: const Icon(Icons.my_location, color: Colors.blue, size: 36)), Marker(point: destino, width: 48, height: 48, child: const Icon(Icons.location_pin, color: Colors.red, size: 42))])]))),
        const SizedBox(height: 8),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(caminhada.titulo, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)), const SizedBox(height: 12), _Info(icon: Icons.straighten, label: 'Distância', value: '${caminhada.distanciaKm.toStringAsFixed(2)} km'), _Info(icon: Icons.timer_outlined, label: 'Tempo estimado', value: '${caminhada.tempoMin} min'), _Info(icon: Icons.local_fire_department_outlined, label: 'Gasto calórico', value: '${caminhada.calorias.toStringAsFixed(0)} kcal')]))),
        const SizedBox(height: 8),
        if (caminhada.fotoPath == null || !File(caminhada.fotoPath!).existsSync()) Card(child: InkWell(onTap: tirarFoto, child: const Padding(padding: EdgeInsets.symmetric(vertical: 30), child: Column(children: [Icon(Icons.camera_alt_outlined, size: 62), SizedBox(height: 8), Text('Adicionar foto da caminhada', style: TextStyle(fontWeight: FontWeight.bold))])))) else Card(clipBehavior: Clip.antiAlias, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Image.file(File(caminhada.fotoPath!), width: double.infinity, height: 300, fit: BoxFit.cover), Padding(padding: const EdgeInsets.all(12), child: OutlinedButton.icon(onPressed: tirarFoto, icon: const Icon(Icons.camera_alt), label: const Text('Tirar outra foto')))])),
        const SizedBox(height: 12),
        Text('Registrada em ${_formatarData(caminhada.data)}', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
      ]),
    );
  }

  String _formatarData(String iso) { final d = DateTime.tryParse(iso)?.toLocal(); if (d == null) return iso; return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}'; }
}

class _Info extends StatelessWidget { final IconData icon; final String label; final String value; const _Info({required this.icon, required this.label, required this.value}); @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(children: [Icon(icon, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 12), Expanded(child: Text(label)), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))])); }
