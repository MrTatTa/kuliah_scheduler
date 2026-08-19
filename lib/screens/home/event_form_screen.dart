import 'package:flutter/material.dart';
import '../../models/event.dart';
import '../../services/database_service.dart';

class EventFormScreen extends StatefulWidget {
  final Event? event;
  final DateTime? initialDate;

  const EventFormScreen({super.key, this.event, this.initialDate});

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();

  late DateTime _tanggal;
  TimeOfDay _jamMulai = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _jamSelesai = const TimeOfDay(hour: 9, minute: 0);
  String _warna = '0xFF009688';

  final List<Map<String, dynamic>> _warnaOptions = [
    {'label': 'Teal', 'value': '0xFF009688'},
    {'label': 'Hijau', 'value': '0xFF4CAF50'},
    {'label': 'Biru', 'value': '0xFF2196F3'},
    {'label': 'Ungu', 'value': '0xFF6C63FF'},
    {'label': 'Orange', 'value': '0xFFFF9800'},
    {'label': 'Merah', 'value': '0xFFF44336'},
    {'label': 'Pink', 'value': '0xFFE91E63'},
    {'label': 'Coklat', 'value': '0xFF795548'},
  ];

  bool get _isEdit => widget.event != null;

  @override
  void initState() {
    super.initState();
    _tanggal = widget.initialDate ?? DateTime.now();
    if (_isEdit) {
      final e = widget.event!;
      _judulController.text = e.judul;
      _deskripsiController.text = e.deskripsi ?? '';
      _tanggal = e.tanggal;
      _jamMulai = _parseTime(e.jamMulai);
      _jamSelesai = _parseTime(e.jamSelesai);
      _warna = e.warna;
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  TimeOfDay _parseTime(String t) {
    final p = t.split(':');
    return TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _formatDate(DateTime d) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final event = Event(
      id: _isEdit ? widget.event!.id : DatabaseService.generateId(),
      judul: _judulController.text.trim(),
      deskripsi: _deskripsiController.text.trim().isEmpty
          ? null
          : _deskripsiController.text.trim(),
      tanggal: _tanggal,
      jamMulai: _formatTime(_jamMulai),
      jamSelesai: _formatTime(_jamSelesai),
      warna: _warna,
    );
    await DatabaseService.saveEvent(event);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Kegiatan' : 'Tambah Kegiatan'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Simpan')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Judul
            TextFormField(
              controller: _judulController,
              decoration: const InputDecoration(
                labelText: 'Judul Kegiatan',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.event_outlined),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),

            // Deskripsi
            TextFormField(
              controller: _deskripsiController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi (opsional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Tanggal
            OutlinedButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _tanggal,
                  firstDate: DateTime(2024),
                  lastDate: DateTime(2027),
                );
                if (picked != null) setState(() => _tanggal = picked);
              },
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text('Tanggal: ${_formatDate(_tanggal)}'),
            ),
            const SizedBox(height: 12),

            // Jam
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showTimePicker(
                          context: context, initialTime: _jamMulai);
                      if (picked != null)
                        setState(() => _jamMulai = picked);
                    },
                    icon: const Icon(Icons.access_time),
                    label: Text('Mulai: ${_formatTime(_jamMulai)}'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showTimePicker(
                          context: context, initialTime: _jamSelesai);
                      if (picked != null)
                        setState(() => _jamSelesai = picked);
                    },
                    icon: const Icon(Icons.access_time),
                    label: Text('Selesai: ${_formatTime(_jamSelesai)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Warna
            Text('Warna', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _warnaOptions.map((opt) {
                final isSelected = _warna == opt['value'];
                final color = Color(int.parse(opt['value']));
                return GestureDetector(
                  onTap: () => setState(() => _warna = opt['value']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onSurface
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check,
                            color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}