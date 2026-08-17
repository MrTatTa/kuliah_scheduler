import 'package:flutter/material.dart';
import '../../models/kelas.dart';
import '../../services/database_service.dart';
import 'kelas_form_screen.dart';
import 'kelas_detail_screen.dart';

class KelasListScreen extends StatefulWidget {
  const KelasListScreen({super.key});

  @override
  State<KelasListScreen> createState() => _KelasListScreenState();
}

class _KelasListScreenState extends State<KelasListScreen> {
  List<Kelas> _kelasList = [];

  final List<String> _hariNames = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _kelasList = DatabaseService.getAllKelas()
        ..sort((a, b) {
          if (a.hariIndex != b.hariIndex) {
            return a.hariIndex.compareTo(b.hariIndex);
          }
          return a.jamMulai.compareTo(b.jamMulai);
        });
    });
  }

  Map<int, List<Kelas>> get _kelasByHari {
    final map = <int, List<Kelas>>{};
    for (final kelas in _kelasList) {
      map.putIfAbsent(kelas.hariIndex, () => []).add(kelas);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kelas',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton.filled(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const KelasFormScreen(),
                        ),
                      );
                      _loadData();
                    },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),

            // List
            Expanded(
              child: _kelasList.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _kelasByHari.keys.length,
                      itemBuilder: (ctx, i) {
                        final hariIndex = _kelasByHari.keys.elementAt(i);
                        final list = _kelasByHari[hariIndex]!;
                        return _buildHariSection(hariIndex, list);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHariSection(int hariIndex, List<Kelas> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 6),
          child: Text(
            _hariNames[hariIndex],
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        ...list.map((kelas) => _buildKelasCard(kelas)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildKelasCard(Kelas kelas) {
    final color = Color(int.parse(kelas.warna));
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 4,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Text(
          kelas.namaMatkul,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${kelas.jamMulai} – ${kelas.jamSelesai} · ${kelas.ruang}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => KelasFormScreen(kelas: kelas),
                  ),
                );
                _loadData();
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Theme.of(context).colorScheme.error,
              onPressed: () => _confirmDelete(kelas),
            ),
          ],
        ),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => KelasDetailScreen(kelas: kelas)),
          );
          _loadData();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            'Belum ada kelas',
            style: TextStyle(
              color: Theme.of(context).colorScheme.outline,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const KelasFormScreen()),
              );
              _loadData();
            },
            child: const Text('Tambah Kelas'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Kelas kelas) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Kelas'),
        content: Text(
          'Hapus "${kelas.namaMatkul}"? Data presensi dan jurnal juga akan terhapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              await DatabaseService.deleteKelas(kelas.id);
              Navigator.pop(ctx);
              _loadData();
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
