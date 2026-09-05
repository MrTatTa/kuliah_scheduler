import 'package:flutter/material.dart';
import '../../models/quest.dart';
import '../../services/database_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/lampiran_picker.dart';

class QuestFormScreen extends StatefulWidget {
  final Quest? quest;
  const QuestFormScreen({super.key, this.quest});

  @override
  State<QuestFormScreen> createState() => _QuestFormScreenState();
}

class _QuestFormScreenState extends State<QuestFormScreen> {
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _matkulController = TextEditingController();

  DateTime _deadline = DateTime.now().add(const Duration(days: 7));
  int _xpReward = 100;
  List<String> _lampiranPaths = [];

  bool get _isEdit => widget.quest != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final q = widget.quest!;
      _judulController.text = q.judul;
      _deskripsiController.text = q.deskripsi ?? '';
      _matkulController.text = q.matkul;
      _deadline = q.deadline;
      _xpReward = q.xpReward;
      _lampiranPaths = List.from(q.lampiranPaths);
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _matkulController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  bool _isSaving = false;

  Future<void> _save() async {
    if (_isSaving) return; // guard: cegah double tap
    if (_judulController.text.trim().isEmpty ||
        _matkulController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul dan mata kuliah wajib diisi')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final quest = Quest(
      id: _isEdit ? widget.quest!.id : DatabaseService.generateId(),
      judul: _judulController.text.trim(),
      deskripsi: _deskripsiController.text.trim().isEmpty
          ? null
          : _deskripsiController.text.trim(),
      matkul: _matkulController.text.trim(),
      deadline: _deadline,
      status: _isEdit ? widget.quest!.status : StatusQuest.belum,
      xpReward: _xpReward,
      lampiran: _lampiranPaths,
    );

    await DatabaseService.saveQuest(quest);
    await NotificationService.scheduleQuestReminders(quest);

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Quest' : 'Quest Baru'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Simpan'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextFormField(
            controller: _judulController,
            decoration: const InputDecoration(
              labelText: 'Judul Quest',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.task_alt),
            ),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _matkulController,
            decoration: const InputDecoration(
              labelText: 'Mata Kuliah',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.school_outlined),
            ),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _deskripsiController,
            decoration: const InputDecoration(
              labelText: 'Deskripsi (opsional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          // Deadline picker
          OutlinedButton.icon(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _deadline,
                firstDate: DateTime.now(),
                lastDate: DateTime(2027),
              );
              if (picked != null) setState(() => _deadline = picked);
            },
            icon: const Icon(Icons.flag_outlined),
            label: Text('Deadline: ${_formatDate(_deadline)}'),
          ),
          const SizedBox(height: 16),

          // XP slider
          Row(
            children: [
              const Text('XP Reward:'),
              const SizedBox(width: 8),
              Expanded(
                child: Slider(
                  value: _xpReward.toDouble(),
                  min: 50,
                  max: 500,
                  divisions: 9,
                  label: '$_xpReward XP',
                  onChanged: (v) => setState(() => _xpReward = v.toInt()),
                ),
              ),
              SizedBox(
                width: 60,
                child: Text(
                  '$_xpReward XP',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Lampiran
          LampiranPicker(
            paths: _lampiranPaths,
            onChanged: (updated) => setState(() => _lampiranPaths = updated),
          ),
          const SizedBox(height: 32),

          FilledButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(_isEdit ? 'Simpan Perubahan' : 'Buat Quest'),
          ),
        ],
      ),
    );
  }
}
