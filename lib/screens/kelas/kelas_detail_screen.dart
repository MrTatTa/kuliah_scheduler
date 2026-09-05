import 'package:flutter/material.dart';
import '../../models/kelas.dart';
import '../../models/presensi.dart';
import '../../models/jurnal.dart';
import '../../services/database_service.dart';
import 'kelas_form_screen.dart';

class KelasDetailScreen extends StatefulWidget {
  final Kelas kelas;
  const KelasDetailScreen({super.key, required this.kelas});

  @override
  State<KelasDetailScreen> createState() => _KelasDetailScreenState();
}

class _KelasDetailScreenState extends State<KelasDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Presensi> _presensiList = [];
  List<Jurnal> _jurnalList = [];
  Map<StatusPresensi, int> _rekap = {};

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
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    setState(() {
      _presensiList = DatabaseService.getPresensiByKelas(widget.kelas.id);
      _jurnalList = DatabaseService.getJurnalByKelas(widget.kelas.id);
      _rekap = DatabaseService.getRekapPresensi(widget.kelas.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final kelas = widget.kelas;
    final color = Color(int.parse(kelas.warna));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          SliverAppBar(
            expandedHeight: 240, // naik dari 200
            pinned: true,
            backgroundColor: colorScheme.surface,
            foregroundColor: colorScheme.onSurface,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => KelasFormScreen(kelas: kelas),
                    ),
                  );
                  setState(() {});
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeader(kelas, color, colorScheme),
              collapseMode: CollapseMode.pin,
            ),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Info'),
                Tab(text: 'Presensi'),
                Tab(text: 'Jurnal'),
              ],
              indicatorColor: color,
              labelColor: color,
              unselectedLabelColor: colorScheme.outline,
              dividerColor: colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildInfoTab(kelas, color),
            _buildPresensiTab(color),
            _buildJurnalTab(color),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(Kelas kelas, Color color, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        90,
        20,
        60,
      ), // bawah 60 biar clear dari TabBar
      decoration: BoxDecoration(color: color.withValues(alpha: 0.06)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.school_rounded, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kelas.namaMatkul,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      kelas.dosen,
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _infoPill(
                Icons.calendar_today_rounded,
                _hariNames[kelas.hariIndex],
                color,
              ),
              _infoPill(
                Icons.access_time_rounded,
                '${kelas.jamMulai} – ${kelas.jamSelesai}',
                color,
              ),
              _infoPill(Icons.room_rounded, kelas.ruang, color),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoPill(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
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

  // ── Tab Info ───────────────────────────────────────────────────────────────

  Widget _buildInfoTab(Kelas kelas, Color color) {
    final colorScheme = Theme.of(context).colorScheme;
    final total = _rekap.values.fold(0, (a, b) => a + b);
    final alpa = _rekap[StatusPresensi.alpa] ?? 0;
    final masuk = total - alpa;
    final persen = total == 0 ? 0.0 : masuk / total;
    final persenColor = _getPersenColor(persen);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      children: [
        // Card rekap kehadiran
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Rekap Kehadiran',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: persenColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$total pertemuan',
                      style: TextStyle(
                        fontSize: 11,
                        color: persenColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Persentase besar
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${(persen * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: persenColor,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '$masuk dari $total pertemuan (alpa: $alpa)',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.outline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: persen,
                  minHeight: 8,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(persenColor),
                ),
              ),
              const SizedBox(height: 16),

              // 4 status chips
              Row(
                children: [
                  _rekapBox(
                    'Hadir',
                    _rekap[StatusPresensi.hadir] ?? 0,
                    Colors.green,
                  ),
                  const SizedBox(width: 8),
                  _rekapBox(
                    'Izin',
                    _rekap[StatusPresensi.izin] ?? 0,
                    Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _rekapBox(
                    'Sakit',
                    _rekap[StatusPresensi.sakit] ?? 0,
                    Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  _rekapBox(
                    'Alpa',
                    _rekap[StatusPresensi.alpa] ?? 0,
                    Colors.red,
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Warning kehadiran
        if (total > 0 && persen < 0.75)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Kehadiran di bawah 75%. Perhatikan batas minimal kehadiran!',
                    style: TextStyle(fontSize: 12, color: Colors.red.shade700),
                  ),
                ),
              ],
            ),
          ),

        // Card info detail
        _buildCard(
          child: Column(
            children: [
              _infoRow(Icons.person_rounded, 'Dosen', kelas.dosen, colorScheme),
              _divider(),
              _infoRow(Icons.room_rounded, 'Ruang', kelas.ruang, colorScheme),
              _divider(),
              _infoRow(
                Icons.calendar_today_rounded,
                'Hari',
                _hariNames[kelas.hariIndex],
                colorScheme,
              ),
              _divider(),
              _infoRow(
                Icons.access_time_rounded,
                'Jam',
                '${kelas.jamMulai} – ${kelas.jamSelesai}',
                colorScheme,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _rekapBox(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(fontSize: 13, color: colorScheme.outline),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      Divider(height: 1, color: Colors.grey.withValues(alpha: 0.15));

  // ── Tab Presensi ───────────────────────────────────────────────────────────

  Widget _buildPresensiTab(Color color) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: _presensiList.isEmpty
          ? _buildEmptyState(
              Icons.check_circle_outline_rounded,
              'Belum ada presensi',
              'Tap tombol di bawah untuk catat kehadiran',
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: _presensiList.length,
              itemBuilder: (ctx, i) => _buildPresensiCard(_presensiList[i]),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showTambahPresensi,
        backgroundColor: color,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Catat Presensi'),
      ),
    );
  }

  Widget _buildPresensiCard(Presensi presensi) {
    final statusData = _getStatusData(presensi.status);
    final color = statusData['color'] as Color;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            // Status dot
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                statusData['icon'] as IconData,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pertemuan ${presensi.pertemuanKe}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    _formatDate(presensi.tanggal),
                    style: TextStyle(fontSize: 12, color: colorScheme.outline),
                  ),
                ],
              ),
            ),

            // Status chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusData['label'] as String,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Delete
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                size: 18,
                color: colorScheme.error,
              ),
              onPressed: () async {
                await DatabaseService.deletePresensi(presensi.id);
                _loadData();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTambahPresensi() {
    StatusPresensi selectedStatus = StatusPresensi.hadir;
    DateTime selectedDate = DateTime.now();
    final pertemuanKe = _presensiList.length + 1;
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Pertemuan $pertemuanKe',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Tanggal
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2024),
                    lastDate: DateTime(2027),
                  );
                  if (picked != null) {
                    setModalState(() => selectedDate = picked);
                  }
                },
                icon: const Icon(Icons.calendar_today_rounded),
                label: Text(_formatDate(selectedDate)),
              ),
              const SizedBox(height: 16),

              // Status
              Text(
                'Status kehadiran',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 10),
              Row(
                children: StatusPresensi.values.map((s) {
                  final data = _getStatusData(s);
                  final color = data['color'] as Color;
                  final isSelected = selectedStatus == s;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setModalState(() => selectedStatus = s),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withValues(alpha: 0.15)
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? color : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              data['icon'] as IconData,
                              color: isSelected ? color : colorScheme.outline,
                              size: 20,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data['label'] as String,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? color : colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final presensi = Presensi(
                      id: DatabaseService.generateId(),
                      kelasId: widget.kelas.id,
                      tanggal: selectedDate,
                      pertemuanKe: pertemuanKe,
                      status: selectedStatus,
                    );
                    await DatabaseService.savePresensi(presensi);
                    Navigator.pop(ctx);
                    _loadData();
                  },
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Tab Jurnal ─────────────────────────────────────────────────────────────

  Widget _buildJurnalTab(Color color) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: _jurnalList.isEmpty
          ? _buildEmptyState(
              Icons.book_outlined,
              'Belum ada jurnal',
              'Catat materi setiap pertemuan di sini',
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: _jurnalList.length,
              itemBuilder: (ctx, i) => _buildJurnalCard(_jurnalList[i]),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showTambahJurnal,
        backgroundColor: color,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Jurnal'),
      ),
    );
  }

  Widget _buildJurnalCard(Jurnal jurnal) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = Color(int.parse(widget.kelas.warna));

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showDetailJurnal(jurnal),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Nomor pertemuan
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${jurnal.pertemuanKe}',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: color,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        jurnal.materi,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _formatDate(jurnal.tanggal),
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),

                // Delete
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: colorScheme.error,
                  ),
                  onPressed: () async {
                    await DatabaseService.deleteJurnal(jurnal.id);
                    _loadData();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetailJurnal(Jurnal jurnal) {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Pertemuan ${jurnal.pertemuanKe}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              jurnal.materi,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(jurnal.tanggal),
              style: TextStyle(fontSize: 12, color: colorScheme.outline),
            ),
            if (jurnal.catatan != null && jurnal.catatan!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Catatan',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(jurnal.catatan!, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showTambahJurnal() {
    final materiController = TextEditingController();
    final catatanController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    final pertemuanKe = _jurnalList.length + 1;
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Jurnal Pertemuan $pertemuanKe',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2024),
                    lastDate: DateTime(2027),
                  );
                  if (picked != null) {
                    setModalState(() => selectedDate = picked);
                  }
                },
                icon: const Icon(Icons.calendar_today_rounded),
                label: Text(_formatDate(selectedDate)),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: materiController,
                decoration: const InputDecoration(
                  labelText: 'Materi pertemuan',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: catatanController,
                decoration: const InputDecoration(
                  labelText: 'Catatan (opsional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    if (materiController.text.trim().isEmpty) return;
                    final jurnal = Jurnal(
                      id: DatabaseService.generateId(),
                      kelasId: widget.kelas.id,
                      tanggal: selectedDate,
                      pertemuanKe: pertemuanKe,
                      materi: materiController.text.trim(),
                      catatan: catatanController.text.trim().isEmpty
                          ? null
                          : catatanController.text.trim(),
                    );
                    await DatabaseService.saveJurnal(jurnal);
                    Navigator.pop(ctx);
                    _loadData();
                  },
                  child: const Text('Simpan Jurnal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _buildCard({required Widget child}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildEmptyState(IconData icon, String title, String subtitle) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: colorScheme.outline),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: colorScheme.outline),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getPersenColor(double persen) {
    if (persen >= 0.75) return Colors.green;
    if (persen >= 0.6) return Colors.orange;
    return Colors.red;
  }

  Map<String, dynamic> _getStatusData(StatusPresensi status) {
    switch (status) {
      case StatusPresensi.hadir:
        return {
          'label': 'Hadir',
          'color': Colors.green,
          'icon': Icons.check_circle_rounded,
        };
      case StatusPresensi.izin:
        return {
          'label': 'Izin',
          'color': Colors.blue,
          'icon': Icons.info_rounded,
        };
      case StatusPresensi.sakit:
        return {
          'label': 'Sakit',
          'color': Colors.orange,
          'icon': Icons.healing_rounded,
        };
      case StatusPresensi.alpa:
        return {
          'label': 'Alpa',
          'color': Colors.red,
          'icon': Icons.cancel_rounded,
        };
    }
  }

  String _formatDate(DateTime date) {
    final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
