import 'package:flutter/material.dart';
import '../../models/quest.dart';
import '../../services/database_service.dart';
import '../../services/notification_service.dart';

class QuestScreen extends StatefulWidget {
  const QuestScreen({super.key});

  @override
  State<QuestScreen> createState() => _QuestScreenState();
}

class _QuestScreenState extends State<QuestScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Quest> _activeQuests = [];
  List<Quest> _completedQuests = [];
  int _totalXP = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    final completed = DatabaseService.getCompletedQuests();
    setState(() {
      _activeQuests = DatabaseService.getActiveQuests();
      _completedQuests = completed;
      _totalXP = completed.fold(0, (sum, q) => sum + q.xpReward);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header + XP bar
            _buildHeader(),

            // Tab bar
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: 'Aktif (${_activeQuests.length})'),
                Tab(text: 'Selesai (${_completedQuests.length})'),
              ],
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildActiveTab(), _buildCompletedTab()],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showQuestForm,
        icon: const Icon(Icons.add),
        label: const Text('Quest Baru'),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    final level = (_totalXP / 500).floor() + 1;
    final xpInLevel = _totalXP % 500;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          // Judul
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quest Board',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_activeQuests.length} quest aktif',
                  style: TextStyle(color: colorScheme.outline, fontSize: 13),
                ),
              ],
            ),
          ),

          // Level & XP badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Level $level',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: xpInLevel / 500,
                      minHeight: 6,
                      backgroundColor: colorScheme.primary.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$xpInLevel / 500 XP',
                  style: TextStyle(fontSize: 10, color: colorScheme.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab Aktif ──────────────────────────────────────────────────────────────

  Widget _buildActiveTab() {
    if (_activeQuests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              'Semua quest selesai! 🎉',
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: _activeQuests.length,
      itemBuilder: (ctx, i) => _buildQuestCard(_activeQuests[i]),
    );
  }

  Widget _buildQuestCard(Quest quest) {
    final urgency = _getUrgency(quest);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          // Urgency bar di atas
          if (urgency['show'] as bool)
            Container(
              width: double.infinity,
              color: (urgency['color'] as Color).withOpacity(0.15),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  Icon(
                    urgency['icon'] as IconData,
                    size: 14,
                    color: urgency['color'] as Color,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    urgency['label'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: urgency['color'] as Color,
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status icon
                GestureDetector(
                  onTap: () => _cycleStatus(quest),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _getStatusColor(quest.status),
                        width: 2,
                      ),
                      color: _getStatusColor(quest.status).withOpacity(0.1),
                    ),
                    child: Icon(
                      _getStatusIcon(quest.status),
                      size: 18,
                      color: _getStatusColor(quest.status),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Konten
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              quest.judul,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          // XP badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '+${quest.xpReward} XP',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.school_outlined,
                            size: 13,
                            color: colorScheme.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            quest.matkul,
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                      if (quest.deskripsi != null &&
                          quest.deskripsi!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          quest.deskripsi!,
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.flag_outlined,
                            size: 13,
                            color: urgency['color'] as Color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Deadline: ${_formatDate(quest.deadline)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: urgency['color'] as Color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          // Status chip
                          _buildStatusChip(quest.status),
                        ],
                      ),
                    ],
                  ),
                ),

                // Menu
                PopupMenuButton<String>(
                  onSelected: (val) => _handleMenu(val, quest),
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Hapus', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                  child: const Icon(Icons.more_vert, size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab Selesai ────────────────────────────────────────────────────────────

  Widget _buildCompletedTab() {
    if (_completedQuests.isEmpty) {
      return Center(
        child: Text(
          'Belum ada quest yang selesai',
          style: TextStyle(color: Theme.of(context).colorScheme.outline),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: _completedQuests.length,
      itemBuilder: (ctx, i) => _buildCompletedCard(_completedQuests[i]),
    );
  }

  Widget _buildCompletedCard(Quest quest) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(Icons.check, color: Colors.white, size: 20),
        ),
        title: Text(
          quest.judul,
          style: const TextStyle(
            decoration: TextDecoration.lineThrough,
            color: Colors.grey,
          ),
        ),
        subtitle: Text(quest.matkul),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '+${quest.xpReward} XP',
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        onLongPress: () async {
          // Long press untuk unmark selesai
          quest.status = StatusQuest.belum;
          await DatabaseService.saveQuest(quest);
          _loadData();
        },
      ),
    );
  }

  // ── Form Quest ─────────────────────────────────────────────────────────────

  void _showQuestForm({Quest? quest}) {
    final isEdit = quest != null;
    final judulController = TextEditingController(text: quest?.judul ?? '');
    final deskripsiController = TextEditingController(
      text: quest?.deskripsi ?? '',
    );
    final matkulController = TextEditingController(text: quest?.matkul ?? '');
    DateTime selectedDeadline =
        quest?.deadline ?? DateTime.now().add(const Duration(days: 7));
    int xpReward = quest?.xpReward ?? 100;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEdit ? 'Edit Quest' : 'Quest Baru',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Judul
                TextField(
                  controller: judulController,
                  decoration: const InputDecoration(
                    labelText: 'Judul Quest',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.task_alt),
                  ),
                ),
                const SizedBox(height: 12),

                // Matkul
                TextField(
                  controller: matkulController,
                  decoration: const InputDecoration(
                    labelText: 'Mata Kuliah',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.school_outlined),
                  ),
                ),
                const SizedBox(height: 12),

                // Deskripsi
                TextField(
                  controller: deskripsiController,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi (opsional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),

                // Deadline
                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDeadline,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2027),
                    );
                    if (picked != null) {
                      setModalState(() => selectedDeadline = picked);
                    }
                  },
                  icon: const Icon(Icons.flag_outlined),
                  label: Text('Deadline: ${_formatDate(selectedDeadline)}'),
                ),
                const SizedBox(height: 12),

                // XP reward
                Row(
                  children: [
                    const Text('XP Reward:'),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Slider(
                        value: xpReward.toDouble(),
                        min: 50,
                        max: 500,
                        divisions: 9,
                        label: '$xpReward XP',
                        onChanged: (v) =>
                            setModalState(() => xpReward = v.toInt()),
                      ),
                    ),
                    Text(
                      '$xpReward XP',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      if (judulController.text.trim().isEmpty ||
                          matkulController.text.trim().isEmpty)
                        return;

                      final newQuest = Quest(
                        id: isEdit ? quest.id : DatabaseService.generateId(),
                        judul: judulController.text.trim(),
                        deskripsi: deskripsiController.text.trim().isEmpty
                            ? null
                            : deskripsiController.text.trim(),
                        matkul: matkulController.text.trim(),
                        deadline: selectedDeadline,
                        status: isEdit ? quest.status : StatusQuest.belum,
                        xpReward: xpReward,
                      );

                      await DatabaseService.saveQuest(newQuest);
                      await NotificationService.scheduleQuestReminders(
                        newQuest,
                      );

                      Navigator.pop(ctx);
                      _loadData();
                    },
                    child: Text(isEdit ? 'Simpan' : 'Buat Quest'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Helper ─────────────────────────────────────────────────────────────────

  Future<void> _cycleStatus(Quest quest) async {
    final next = {
      StatusQuest.belum: StatusQuest.dikerjakan,
      StatusQuest.dikerjakan: StatusQuest.selesai,
      StatusQuest.selesai: StatusQuest.belum,
    };
    quest.status = next[quest.status]!;

    if (quest.status == StatusQuest.selesai) {
      await NotificationService.cancelQuestReminders(quest.id);
      _showXPPopup(quest.xpReward);
    } else {
      await NotificationService.scheduleQuestReminders(quest);
    }

    await DatabaseService.saveQuest(quest);
    _loadData();
  }

  void _showXPPopup(int xp) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.star, color: Colors.amber),
            const SizedBox(width: 8),
            Text('+$xp XP diperoleh! Quest selesai! 🎉'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handleMenu(String action, Quest quest) async {
    if (action == 'edit') {
      _showQuestForm(quest: quest);
    } else if (action == 'delete') {
      await NotificationService.cancelQuestReminders(quest.id);
      await DatabaseService.deleteQuest(quest.id);
      _loadData();
    }
  }

  Widget _buildStatusChip(StatusQuest status) {
    final data = {
      StatusQuest.belum: {'label': 'Belum', 'color': Colors.grey},
      StatusQuest.dikerjakan: {'label': 'Dikerjakan', 'color': Colors.blue},
      StatusQuest.selesai: {'label': 'Selesai', 'color': Colors.green},
    };

    final d = data[status]!;
    final color = d['color'] as Color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        d['label'] as String,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStatusColor(StatusQuest status) {
    switch (status) {
      case StatusQuest.belum:
        return Colors.grey;
      case StatusQuest.dikerjakan:
        return Colors.blue;
      case StatusQuest.selesai:
        return Colors.green;
    }
  }

  IconData _getStatusIcon(StatusQuest status) {
    switch (status) {
      case StatusQuest.belum:
        return Icons.radio_button_unchecked;
      case StatusQuest.dikerjakan:
        return Icons.timelapse;
      case StatusQuest.selesai:
        return Icons.check_circle;
    }
  }

  Map<String, dynamic> _getUrgency(Quest quest) {
    if (quest.isOverdue) {
      return {
        'show': true,
        'label': 'Sudah lewat deadline!',
        'color': Colors.red,
        'icon': Icons.warning,
      };
    }
    final days = quest.daysUntilDeadline;
    if (days == 0) {
      return {
        'show': true,
        'label': 'Deadline hari ini!',
        'color': Colors.red,
        'icon': Icons.warning,
      };
    }
    if (days == 1) {
      return {
        'show': true,
        'label': 'Deadline besok!',
        'color': Colors.orange,
        'icon': Icons.schedule,
      };
    }
    if (days == 2) {
      return {
        'show': true,
        'label': 'Deadline 2 hari lagi',
        'color': Colors.amber,
        'icon': Icons.schedule,
      };
    }
    return {
      'show': false,
      'label': '',
      'color': Theme.of(context).colorScheme.outline,
      'icon': Icons.flag_outlined,
    };
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
}
