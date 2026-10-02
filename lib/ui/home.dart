import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/caminhada.dart';
import '../services/arquivo_service.dart';
import 'nova_caminhada.dart';
import 'splash.dart';
import 'detalhes_caminhada.dart';
import 'style/theme.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Caminhada> caminhadas = [];

  @override
  void initState() { super.initState(); carregar(); }

  Future<void> carregar() async {
    final data = await ArquivoService.carregar();
    if (mounted) setState(() => caminhadas = data);
  }

  Future<void> adicionar() async {
    final nova = await Navigator.push<Caminhada>(context, MaterialPageRoute(builder: (_) => const NovaCaminhada()));
    if (nova != null) {
      setState(() => caminhadas.insert(0, nova));
      await ArquivoService.salvar(caminhadas);
    }
  }

  Future<void> abrirDetalhes(Caminhada caminhada) async {
    final atualizada = await Navigator.push<Caminhada>(context, MaterialPageRoute(builder: (_) => DetalhesCaminhada(caminhada: caminhada)));
    if (atualizada != null) {
      final index = caminhadas.indexWhere((e) => e.id == atualizada.id);
      if (index >= 0) {
        setState(() => caminhadas[index] = atualizada);
        await ArquivoService.salvar(caminhadas);
      }
    }
  }

  void sair() {
    showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja fechar o aplicativo?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sair')),
        ],
      ),
    ).then((confirmado) {
      if (confirmado == true) SystemNavigator.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Caminhadas')),
      drawer: Drawer(
        child: SafeArea(child: ListView(children: [
          DrawerHeader(decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [Icon(Icons.directions_walk, color: Colors.white, size: 48), SizedBox(height: 8), Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))])),
          ListTile(leading: const Icon(Icons.home), title: const Text('Caminhadas'), onTap: () => Navigator.pop(context)),
          ListTile(leading: const Icon(Icons.wb_sunny_outlined), title: const Text('Splash'), onTap: () { Navigator.pop(context); Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Splash())); }),
          ListTile(leading: const Icon(Icons.dark_mode), title: const Text('Tema claro/escuro'), onTap: () { AppTheme.alternarTema(); Navigator.pop(context); }),
          ListTile(leading: const Icon(Icons.logout), title: const Text('Sair'), onTap: () { Navigator.pop(context); sair(); }),
        ])),
      ),
      body: caminhadas.isEmpty ? const _Vazio() : ListView.builder(padding: const EdgeInsets.all(12), itemCount: caminhadas.length, itemBuilder: (_, i) => _CardCaminhada(caminhada: caminhadas[i], onTap: () => abrirDetalhes(caminhadas[i]))),
      floatingActionButton: FloatingActionButton(onPressed: adicionar, child: const Icon(Icons.add)),
    );
  }
}

class _Vazio extends StatelessWidget {
  const _Vazio();
  @override Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.directions_walk, size: 90, color: Theme.of(context).colorScheme.primary), const SizedBox(height: 16), const Text('Nenhuma caminhada cadastrada', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center), const SizedBox(height: 8), const Text('Toque no + para registrar sua primeira caminhada.', textAlign: TextAlign.center)])));
}

class _CardCaminhada extends StatelessWidget {
  final Caminhada caminhada; final VoidCallback onTap;
  const _CardCaminhada({required this.caminhada, required this.onTap});
  @override Widget build(BuildContext context) => Card(margin: const EdgeInsets.only(bottom: 12), clipBehavior: Clip.antiAlias, child: ListTile(contentPadding: const EdgeInsets.all(10), leading: SizedBox(width: 72, height: 72, child: caminhada.fotoPath != null && File(caminhada.fotoPath!).existsSync() ? Image.file(File(caminhada.fotoPath!), fit: BoxFit.cover) : const DecoratedBox(decoration: BoxDecoration(color: Color(0xFFE0F2F1)), child: Icon(Icons.directions_walk, size: 38))), title: Text(caminhada.titulo, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('${caminhada.distanciaKm.toStringAsFixed(2)} km • ${caminhada.tempoMin} min\n${caminhada.calorias.toStringAsFixed(0)} kcal'), trailing: const Icon(Icons.chevron_right), onTap: onTap));
}
