import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/kelas.dart';
import '../../models/event.dart';
import '../../services/database_service.dart';
import '../kelas/kelas_list_screen.dart';
import '../quest/quest_screen.dart';

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
    final hariIndex = _selectedDay.weekday - 1; // Monday=0
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

  Widget _buildHomePage() {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Jadwal Ku',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton.filled(
                  onPressed: _showAddOptions,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),

          // Kalender
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2026, 12, 31),
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
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),

          const Divider(height: 1),

          // Jadwal hari ini
          Expanded(
            child: _kelasHariIni.isEmpty && _eventHariIni.isEmpty
                ? _buildEmptyState()
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (_kelasHariIni.isNotEmpty) ...[
                        _buildSectionLabel('Kelas', Icons.school, Colors.blue),
                        const SizedBox(height: 8),
                        ..._kelasHariIni.map(_buildKelasCard),
                        const SizedBox(height: 16),
                      ],
                      if (_eventHariIni.isNotEmpty) ...[
                        _buildSectionLabel(
                          'Kegiatan',
                          Icons.event,
                          Colors.green,
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

  Widget _buildSectionLabel(String label, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: color,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildKelasCard(Kelas kelas) {
    final color = Color(int.parse(kelas.warna));
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
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
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Nanti navigate ke detail kelas
        },
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    final color = Color(int.parse(event.warna));
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
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
          event.judul,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('${event.jamMulai} – ${event.jamSelesai}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Nanti navigate ke detail event
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
            Icons.weekend_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            'Tidak ada jadwal hari ini',
            style: TextStyle(
              color: Theme.of(context).colorScheme.outline,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Tambah Kelas'),
              onTap: () {
                Navigator.pop(ctx);
                // Nanti navigate ke form tambah kelas
              },
            ),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Tambah Kegiatan'),
              onTap: () {
                Navigator.pop(ctx);
                // Nanti navigate ke form tambah event
              },
            ),
            ListTile(
              leading: const Icon(Icons.task),
              title: const Text('Tambah Quest'),
              onTap: () {
                Navigator.pop(ctx);
                // Nanti navigate ke form tambah quest
              },
            ),
          ],
        ),
      ),
    );
  }
}
