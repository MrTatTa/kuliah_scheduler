import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/kelas.dart';
import '../../models/event.dart';
import '../../services/database_service.dart';
import '../kelas/kelas_list_screen.dart';
import '../kelas/kelas_detail_screen.dart';
import '../kelas/kelas_form_screen.dart';
import '../quest/quest_screen.dart';
import 'event_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  int _currentIndex = 0;

  List<Kelas> _kelasHariIni = [];
  List<Event> _eventHariIni = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final hariIndex = _selectedDay.weekday - 1;
    setState(() {
      _kelasHariIni = DatabaseService.getKelasByHari(hariIndex);
      _eventHariIni = DatabaseService.getEventsByDate(_selectedDay);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomePage(),
      const KelasListScreen(),
      const QuestScreen(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Jadwal',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'Kelas',
          ),
          NavigationDestination(
            icon: Icon(Icons.task_outlined),
            selectedIcon: Icon(Icons.task),
            label: 'Quest',
          ),
        ],
      ),
    );
  }

  // ── Home Page ──────────────────────────────────────────────────────────────

  Widget _buildHomePage() {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final greeting = now.hour < 11
        ? 'Selamat pagi'
        : now.hour < 15
        ? 'Selamat siang'
        : now.hour < 18
        ? 'Selamat sore'
        : 'Selamat malam';

    return SafeArea(
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
                        greeting,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Jadwal Ku',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                      ),
                    ],
                  ),
                ),
                _buildAddButton(),
              ],
            ),
          ),

          // ── Kalender ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TableCalendar(
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2027, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: CalendarFormat.week,
              startingDayOfWeek: StartingDayOfWeek.monday,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _loadData();
              },
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
                weekendTextStyle: TextStyle(
                  color: colorScheme.error.withOpacity(0.7),
                ),
                outsideDaysVisible: false,
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: false,
                titleTextStyle: Theme.of(context).textTheme.titleSmall!
                    .copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  color: colorScheme.outline,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: colorScheme.outline,
                ),
                headerPadding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.outline,
                ),
                weekendStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.error.withOpacity(0.6),
                ),
              ),
            ),
          ),

          // ── Divider & label tanggal ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _isToday(_selectedDay)
                      ? 'Hari ini'
                      : _isTomorrow(_selectedDay)
                      ? 'Besok'
                      : _formatHeaderDate(_selectedDay),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_kelasHariIni.length + _eventHariIni.length} jadwal',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: colorScheme.outline),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── List jadwal ──
          Expanded(
            child: _kelasHariIni.isEmpty && _eventHariIni.isEmpty
                ? _buildEmptyState()
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    children: [
                      if (_kelasHariIni.isNotEmpty) ...[
                        _buildSectionPill(
                          'Kelas',
                          Icons.school_rounded,
                          colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        ..._kelasHariIni.map(_buildKelasCard),
                        const SizedBox(height: 16),
                      ],
                      if (_eventHariIni.isNotEmpty) ...[
                        _buildSectionPill(
                          'Kegiatan',
                          Icons.event_rounded,
                          Colors.teal,
                        ),
                        const SizedBox(height: 8),
                        ..._eventHariIni.map(_buildEventCard),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ── Add button ─────────────────────────────────────────────────────────────

  Widget _buildAddButton() {
    return IconButton.filled(
      onPressed: _showAddOptions,
      icon: const Icon(Icons.add),
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  // ── Section pill ───────────────────────────────────────────────────────────

  Widget _buildSectionPill(String label, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Kelas card ─────────────────────────────────────────────────────────────

  Widget _buildKelasCard(Kelas kelas) {
    final color = Color(int.parse(kelas.warna));
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Color indicator
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
                      ),
                      const SizedBox(height: 3),
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
                          Text(
                            kelas.ruang,
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Dosen chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _shortName(kelas.dosen),
                    style: TextStyle(
                      fontSize: 11,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Event card ─────────────────────────────────────────────────────────────

  Widget _buildEventCard(Event event) {
    final color = Color(int.parse(event.warna));
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
          onTap: () {}, // nanti bisa tambah detail event
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.judul,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 12,
                            color: colorScheme.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${event.jamMulai} – ${event.jamSelesai}',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                      if (event.deskripsi != null &&
                          event.deskripsi!.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          event.deskripsi!,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
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
              Icons.coffee_rounded,
              size: 36,
              color: colorScheme.outline,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada jadwal',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Waktu santai nih ☕',
            style: TextStyle(fontSize: 13, color: colorScheme.outline),
          ),
        ],
      ),
    );
  }

  // ── Bottom sheet tambah ────────────────────────────────────────────────────

  void _showAddOptions() {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Tambah Jadwal',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _addOptionTile(
                ctx,
                icon: Icons.school_rounded,
                color: colorScheme.primary,
                title: 'Tambah Kelas',
                subtitle: 'Jadwal perkuliahan rutin',
                onTap: () async {
                  Navigator.pop(ctx);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const KelasFormScreen()),
                  );
                  _loadData();
                },
              ),
              const SizedBox(height: 8),
              _addOptionTile(
                ctx,
                icon: Icons.event_rounded,
                color: Colors.teal,
                title: 'Tambah Kegiatan',
                subtitle: 'Event atau kegiatan satu kali',
                onTap: () async {
                  Navigator.pop(ctx);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          EventFormScreen(initialDate: _selectedDay),
                    ),
                  );
                  _loadData();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _addOptionTile(
    BuildContext ctx, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withOpacity(0.06),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helper ─────────────────────────────────────────────────────────────────

  bool _isToday(DateTime date) => isSameDay(date, DateTime.now());
  bool _isTomorrow(DateTime date) =>
      isSameDay(date, DateTime.now().add(const Duration(days: 1)));

  String _formatHeaderDate(DateTime date) {
    final days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
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
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }

  String _shortName(String name) {
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0];
    return '${parts[0]} ${parts[1][0]}.';
  }
}
