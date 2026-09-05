import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/quest.dart';
import '../../services/database_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/lampiran_picker.dart';
import 'quest_form_screen.dart';

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
            _buildHeader(),
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: 'Aktif (${_activeQuests.length})'),
                Tab(text: 'Selesai (${_completedQuests.length})'),
              ],
            ),
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
        onPressed: () => _openQuestForm(),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quest Board',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
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
                      backgroundColor: colorScheme.primary.withValues(
                        alpha: 0.2,
                      ),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openQuestDetail(quest),
          child: Column(
            children: [
              // Urgency banner
              if (urgency['show'] as bool)
                Container(
                  width: double.infinity,
                  color: (urgency['color'] as Color).withValues(alpha: 0.12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
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
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status toggle
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
                          color: _getStatusColor(
                            quest.status,
                          ).withValues(alpha: 0.1),
                        ),
                        child: Icon(
                          _getStatusIcon(quest.status),
                          size: 18,
                          color: _getStatusColor(quest.status),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Info
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
                              // Lampiran indicator
                              if (quest.lampiranPaths.isNotEmpty) ...[
                                Icon(
                                  Icons.attach_file,
                                  size: 13,
                                  color: colorScheme.outline,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${quest.lampiranPaths.length}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colorScheme.outline,
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
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
                          child: Text(
                            'Hapus',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                      child: const Icon(Icons.more_vert, size: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
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
            color: Colors.green.withValues(alpha: 0.1),
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
        onTap: () => _openQuestDetail(quest),
        onLongPress: () async {
          quest.status = StatusQuest.belum;
          await DatabaseService.saveQuest(quest);
          _loadData();
        },
      ),
    );
  }

  // ── Quest Detail ───────────────────────────────────────────────────────────

  void _openQuestDetail(Quest quest) {
    final colorScheme = Theme.of(context).colorScheme;
    final urgency = _getUrgency(quest);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scrollController) => Column(
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

            // Action bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      quest.judul,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _openQuestForm(quest: quest);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: colorScheme.error),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await _confirmDelete(quest);
                    },
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Konten scrollable
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(20),
                children: [
                  // Info pills
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _detailChip(
                        Icons.school_outlined,
                        quest.matkul,
                        colorScheme.primary,
                      ),
                      _detailChip(
                        Icons.flag_outlined,
                        'Deadline: ${_formatDate(quest.deadline)}',
                        urgency['color'] as Color,
                      ),
                      _detailChip(
                        Icons.star_outline,
                        '+${quest.xpReward} XP',
                        Colors.amber,
                      ),
                    ],
                  ),

                  // Status selector
                  const SizedBox(height: 20),
                  Text('Status', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 10),
                  Row(
                    children: StatusQuest.values.map((s) {
                      final isSelected = quest.status == s;
                      final color = _getStatusColor(s);
                      final labels = {
                        StatusQuest.belum: 'Belum',
                        StatusQuest.dikerjakan: 'Dikerjakan',
                        StatusQuest.selesai: 'Selesai',
                      };
                      return Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            Navigator.pop(ctx);
                            quest.status = s;
                            if (s == StatusQuest.selesai) {
                              await NotificationService.cancelQuestReminders(
                                quest.id,
                              );
                              _showXPPopup(quest.xpReward);
                            } else {
                              await NotificationService.scheduleQuestReminders(
                                quest,
                              );
                            }
                            await DatabaseService.saveQuest(quest);
                            _loadData();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.only(right: 8),
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
                                  _getStatusIcon(s),
                                  color: isSelected
                                      ? color
                                      : colorScheme.outline,
                                  size: 20,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  labels[s]!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? color
                                        : colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // Deskripsi
                  if (quest.deskripsi != null &&
                      quest.deskripsi!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Deskripsi',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        quest.deskripsi!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],

                  // Lampiran
                  if (quest.lampiranPaths.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Lampiran',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: quest.lampiranPaths.map((path) {
                        final isImage =
                            path.toLowerCase().endsWith('.jpg') ||
                            path.toLowerCase().endsWith('.jpeg') ||
                            path.toLowerCase().endsWith('.png') ||
                            path.toLowerCase().endsWith('.webp');
                        final fileName = path.split('/').last;

                        return GestureDetector(
                          onTap: () => _openLampiran(path),
                          child: isImage
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    File(path),
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: colorScheme.outlineVariant,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.insert_drive_file_outlined,
                                        color: colorScheme.primary,
                                        size: 32,
                                      ),
                                      const SizedBox(height: 6),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                        ),
                                        child: Text(
                                          fileName,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: colorScheme.outline,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
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
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _openLampiran(String path) {
    // Untuk gambar, tampilkan full screen
    final isImage =
        path.toLowerCase().endsWith('.jpg') ||
        path.toLowerCase().endsWith('.jpeg') ||
        path.toLowerCase().endsWith('.png') ||
        path.toLowerCase().endsWith('.webp');

    if (isImage) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
            body: Center(
              child: InteractiveViewer(child: Image.file(File(path))),
            ),
          ),
        ),
      );
    } else {
      // Untuk file non-gambar, tampilkan snackbar dengan path
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File: ${path.split('/').last}'),
          action: SnackBarAction(label: 'OK', onPressed: () {}),
        ),
      );
    }
  }

  // ── Form Quest ─────────────────────────────────────────────────────────────

  void _openQuestForm({Quest? quest}) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => QuestFormScreen(quest: quest)),
    ).then((result) {
      if (result == true) {
        _loadData();
        // Kalau tambah baru, pindah ke tab aktif
        if (quest == null) {
          _tabController.animateTo(0);
        }
        // Tunjukkan snackbar konfirmasi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  quest == null
                      ? 'Quest berhasil dibuat!'
                      : 'Quest berhasil diperbarui!',
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  Future<void> _confirmDelete(Quest quest) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Quest'),
        content: Text(
          'Hapus "${quest.judul}"? Tindakan ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await NotificationService.cancelQuestReminders(quest.id);
      await DatabaseService.deleteQuest(quest.id);
      _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quest dihapus'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

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

  void _handleMenu(String action, Quest quest) {
    if (action == 'edit') {
      _openQuestForm(quest: quest);
    } else if (action == 'delete') {
      _confirmDelete(quest);
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
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
    if (days == 0)
      return {
        'show': true,
        'label': 'Deadline hari ini!',
        'color': Colors.red,
        'icon': Icons.warning,
      };
    if (days == 1)
      return {
        'show': true,
        'label': 'Deadline besok!',
        'color': Colors.orange,
        'icon': Icons.schedule,
      };
    if (days == 2)
      return {
        'show': true,
        'label': 'Deadline 2 hari lagi',
        'color': Colors.amber,
        'icon': Icons.schedule,
      };
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
