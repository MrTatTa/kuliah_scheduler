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

  int get _totalSks => _kelasList.length * 3; // estimasi kasar

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kelas',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_kelasList.length} mata kuliah',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.outline,
                          ),
                        ),
                      ],
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
                    style: IconButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Summary chips ──
            if (_kelasList.isNotEmpty) ...[
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _summaryChip(
                      Icons.school_rounded,
                      '${_kelasList.length} Matkul',
                      colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    _summaryChip(
                      Icons.calendar_today_rounded,
                      '${_kelasByHari.keys.length} Hari aktif',
                      Colors.teal,
                    ),
                    const SizedBox(width: 8),
                    _summaryChip(
                      Icons.access_time_rounded,
                      '${_getTotalJam()} jam/minggu',
                      Colors.orange,
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // ── List ──
            Expanded(
              child: _kelasList.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
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

  // ── Summary chip ───────────────────────────────────────────────────────────

  Widget _summaryChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ── Hari section ───────────────────────────────────────────────────────────

  Widget _buildHariSection(int hariIndex, List<Kelas> list) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 8),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _hariNames[hariIndex],
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${list.length} kelas',
                style: TextStyle(fontSize: 12, color: colorScheme.outline),
              ),
            ],
          ),
        ),
        ...list.map((kelas) => _buildKelasCard(kelas)),
        const SizedBox(height: 12),
      ],
    );
  }

  // ── Kelas card ─────────────────────────────────────────────────────────────

  Widget _buildKelasCard(Kelas kelas) {
    final color = Color(int.parse(kelas.warna));
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => KelasDetailScreen(kelas: kelas),
              ),
            );
            _loadData();
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
            child: Row(
              children: [
                // Color bar
                Container(
                  width: 4,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kelas.namaMatkul,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: colorScheme.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${kelas.jamMulai} – ${kelas.jamSelesai}',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.outline,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            Icons.room_outlined,
                            size: 12,
                            color: colorScheme.outline,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              kelas.ruang,
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.outline,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Actions
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: colorScheme.outline,
                      ),
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
                      icon: Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: colorScheme.error,
                      ),
                      onPressed: () => _confirmDelete(kelas),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.school_outlined,
              size: 36,
              color: colorScheme.outline,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada kelas',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Tambah jadwal kuliah kamu di sini',
            style: TextStyle(fontSize: 13, color: colorScheme.outline),
          ),
          const SizedBox(height: 20),
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

  // ── Confirm delete ─────────────────────────────────────────────────────────

  void _confirmDelete(Kelas kelas) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Kelas'),
        content: Text(
          'Hapus "${kelas.namaMatkul}"? Data presensi dan jurnal juga akan ikut terhapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
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

  // ── Helper ─────────────────────────────────────────────────────────────────

  int _getTotalJam() {
    int total = 0;
    for (final kelas in _kelasList) {
      final mulai = kelas.jamMulai.split(':');
      final selesai = kelas.jamSelesai.split(':');
      final menitMulai = int.parse(mulai[0]) * 60 + int.parse(mulai[1]);
      final menitSelesai = int.parse(selesai[0]) * 60 + int.parse(selesai[1]);
      total += menitSelesai - menitMulai;
    }
    return (total / 60).ceil();
  }
}
