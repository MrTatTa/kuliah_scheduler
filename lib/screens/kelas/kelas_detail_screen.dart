import 'package:flutter/material.dart';
import '../../models/kelas.dart';

class KelasDetailScreen extends StatelessWidget {
  final Kelas kelas;
  const KelasDetailScreen({super.key, required this.kelas});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(kelas.namaMatkul)),
      body: const Center(child: Text('Detail kelas — coming soon')),
    );
  }
}