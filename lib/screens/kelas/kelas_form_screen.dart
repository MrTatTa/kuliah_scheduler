import 'package:flutter/material.dart';
import '../../models/kelas.dart';
import '../../services/database_service.dart';

class KelasFormScreen extends StatefulWidget {
  final Kelas? kelas; // null = tambah baru, tidak null = edit

  const KelasFormScreen({super.key, this.kelas});

  @override
  State<KelasFormScreen> createState() => _KelasFormScreenState();
}

class _KelasFormScreenState extends State<KelasFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _matkulController = TextEditingController();
  final _dosenController = TextEditingController();
  final _ruangController = TextEditingController();

  int _hariIndex = 0;
  TimeOfDay _jamMulai = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _jamSelesai = const TimeOfDay(hour: 9, minute: 40);
  String _warna = '0xFF6C63FF';

  final List<String> _hariNames = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
  ];

  final List<Map<String, dynamic>> _warnaOptions = [
    {'label': 'Ungu', 'value': '0xFF6C63FF'},
    {'label': 'Biru', 'value': '0xFF2196F3'},
    {'label': 'Hijau', 'value': '0xFF4CAF50'},
    {'label': 'Orange', 'value': '0xFFFF9800'},
    {'label': 'Merah', 'value': '0xFFF44336'},
    {'label': 'Pink', 'value': '0xFFE91E63'},
    {'label': 'Teal', 'value': '0xFF009688'},
    {'label': 'Coklat', 'value': '0xFF795548'},
  ];

  bool get _isEdit => widget.kelas != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final k = widget.kelas!;
      _matkulController.text = k.namaMatkul;
      _dosenController.text = k.dosen;
      _ruangController.text = k.ruang;
      _hariIndex = k.hariIndex;
      _jamMulai = _parseTime(k.jamMulai);
      _jamSelesai = _parseTime(k.jamSelesai);
      _warna = k.warna;
    }
  }

  @override
  void dispose() {
    _matkulController.dispose();
    _dosenController.dispose();
    _ruangController.dispose();
    super.dispose();
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime(bool isMulai) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isMulai ? _jamMulai : _jamSelesai,
    );
    if (picked != null) {
      setState(() {
        if (isMulai) {
          _jamMulai = picked;
        } else {
          _jamSelesai = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final kelas = Kelas(
      id: _isEdit ? widget.kelas!.id : DatabaseService.generateId(),
      namaMatkul: _matkulController.text.trim(),
      dosen: _dosenController.text.trim(),
      ruang: _ruangController.text.trim(),
      hariIndex: _hariIndex,
      jamMulai: _formatTime(_jamMulai),
      jamSelesai: _formatTime(_jamSelesai),
      warna: _warna,
    );

    await DatabaseService.saveKelas(kelas);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Kelas' : 'Tambah Kelas'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Simpan'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Nama matkul
            TextFormField(
              controller: _matkulController,
              decoration: const InputDecoration(
                labelText: 'Nama Mata Kuliah',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.book_outlined),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),

            // Dosen
            TextFormField(
              controller: _dosenController,
              decoration: const InputDecoration(
                labelText: 'Dosen',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outlined),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),

            // Ruang
            TextFormField(
              controller: _ruangController,
              decoration: const InputDecoration(
                labelText: 'Ruang',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.room_outlined),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),

            // Hari
            DropdownButtonFormField<int>(
              initialValue: _hariIndex,
              decoration: const InputDecoration(
                labelText: 'Hari',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today_outlined),
              ),
              items: List.generate(
                _hariNames.length,
                (i) => DropdownMenuItem(value: i, child: Text(_hariNames[i])),
              ),
              onChanged: (v) => setState(() => _hariIndex = v!),
            ),
            const SizedBox(height: 16),

            // Jam
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickTime(true),
                    icon: const Icon(Icons.access_time),
                    label: Text('Mulai: ${_formatTime(_jamMulai)}'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickTime(false),
                    icon: const Icon(Icons.access_time),
                    label: Text('Selesai: ${_formatTime(_jamSelesai)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Warna
            Text(
              'Warna',
              style: Theme.of(context).textTheme.labelLarge,
            ),
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
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
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