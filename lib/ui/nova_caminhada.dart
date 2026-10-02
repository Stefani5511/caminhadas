import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/caminhada.dart';
import '../services/localizacao_service.dart';
import '../services/rota_service.dart';

class NovaCaminhada extends StatefulWidget {
  const NovaCaminhada({super.key});
  @override State<NovaCaminhada> createState() => _NovaCaminhadaState();
}

class _NovaCaminhadaState extends State<NovaCaminhada> {
  final MapController mapController = MapController();
  LatLng? inicio;
  LatLng? destino;
  ResultadoRota? resultado;
  bool carregando = true;
  bool calculando = false;
  String? erro;

  @override
  void initState() { super.initState(); iniciar(); }

  Future<void> iniciar() async {
    try {
      final pos = await LocalizacaoService.obterAtual();
      if (!mounted) return;
      setState(() { inicio = LatLng(pos.latitude, pos.longitude); carregando = false; });
    } catch (e) {
      if (mounted) setState(() { erro = e.toString().replaceFirst('Exception: ', ''); carregando = false; });
    }
  }

  Future<void> selecionar(LatLng ponto) async {
    if (inicio == null || calculando) return;
    setState(() { destino = ponto; resultado = null; calculando = true; erro = null; });
    try {
      final r = await RotaService.calcular(inicioLat: inicio!.latitude, inicioLng: inicio!.longitude, destinoLat: ponto.latitude, destinoLng: ponto.longitude);
      if (mounted) setState(() { resultado = r; calculando = false; });
    } catch (e) {
      if (mounted) setState(() { erro = e.toString().replaceFirst('Exception: ', ''); calculando = false; });
    }
  }

  Future<void> salvar() async {
    if (inicio == null || destino == null || resultado == null) return;
    final controller = TextEditingController();
    final titulo = await showDialog<String>(context: context, builder: (_) => AlertDialog(title: const Text('Salvar caminhada'), content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(labelText: 'Título da caminhada', hintText: 'Ex.: Caminhada no parque')), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')), ElevatedButton(onPressed: () { if (controller.text.trim().isNotEmpty) Navigator.pop(context, controller.text.trim()); }, child: const Text('Salvar'))]));
    if (titulo == null) return;
    final caminhada = Caminhada(id: DateTime.now().microsecondsSinceEpoch.toString(), titulo: titulo, inicioLat: inicio!.latitude, inicioLng: inicio!.longitude, destinoLat: destino!.latitude, destinoLng: destino!.longitude, distanciaKm: resultado!.distanciaKm, tempoMin: resultado!.tempoMin, calorias: resultado!.distanciaKm * 60, rota: resultado!.pontos, data: DateTime.now().toIso8601String());
    if (mounted) Navigator.pop(context, caminhada);
  }

  @override
  Widget build(BuildContext context) {
    if (carregando) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (inicio == null) return Scaffold(appBar: AppBar(title: const Text('Nova caminhada')), body: Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(erro ?? 'Não foi possível obter sua localização.', textAlign: TextAlign.center))));
    final pontos = resultado?.pontos.map((p) => LatLng(p[0], p[1])).toList() ?? [];
    return Scaffold(
      appBar: AppBar(title: const Text('Nova caminhada')),
      body: Stack(children: [
        FlutterMap(mapController: mapController, options: MapOptions(initialCenter: inicio!, initialZoom: 15, onTap: (_, point) => selecionar(point)), children: [
          TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'br.senai.caminhadas'),
          if (pontos.isNotEmpty) PolylineLayer(polylines: [Polyline(points: pontos, strokeWidth: 5, color: Theme.of(context).colorScheme.primary)]),
          MarkerLayer(markers: [Marker(point: inicio!, width: 46, height: 46, child: const Icon(Icons.my_location, color: Colors.blue, size: 38)), if (destino != null) Marker(point: destino!, width: 52, height: 52, child: const Icon(Icons.location_pin, color: Colors.red, size: 46))]),
        ]),
        Positioned(top: 12, left: 12, right: 12, child: Card(child: Padding(padding: const EdgeInsets.all(12), child: Text(destino == null ? 'Toque no mapa para selecionar o destino' : resultado == null ? 'Calculando trajeto...' : 'Distância: ${resultado!.distanciaKm.toStringAsFixed(2)} km')))),
        if (calculando) const Positioned(bottom: 100, left: 0, right: 0, child: Center(child: Card(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator())))),
        if (erro != null) Positioned(bottom: 90, left: 12, right: 12, child: Card(color: Colors.red.shade50, child: Padding(padding: const EdgeInsets.all(10), child: Text(erro!, style: TextStyle(color: Colors.red.shade900))))),
      ]),
      bottomNavigationBar: SafeArea(child: Padding(padding: const EdgeInsets.all(12), child: ElevatedButton.icon(onPressed: resultado == null || calculando ? null : salvar, icon: const Icon(Icons.save), label: const Text('Salvar caminhada')))),
    );
  }
}
