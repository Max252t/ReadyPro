import 'package:flutter/material.dart';

import '../../../../../app/routes.dart';
import '../../../../shared/mock/ui_mock_data.dart';
import '../../../../shared/mock/ui_models.dart';
import '../../../../shared/presentation/layout/root_shell.dart';
import '../../../../shared/presentation/widgets/ui_badge.dart';

class ProgramPage extends StatefulWidget {
  final UiRole role;

  const ProgramPage({super.key, required this.role});

  @override
  State<ProgramPage> createState() => _ProgramPageState();
}

class _ProgramPageState extends State<ProgramPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Set<String> _scheduleTalkIds;

  @override
  void initState() {
    super.initState();
    final uid = UiMockData.userForRole(widget.role).id;
    _scheduleTalkIds = UiMockData.schedule
        .where((s) => s.userId == uid)
        .map((s) => s.talkId)
        .toSet();
    final dateKeys = _uniqueDateKeys();
    _tabController = TabController(length: 1 + dateKeys.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<String> _uniqueDateKeys() {
    final keys = <String>{};
    for (final t in UiMockData.talks) {
      keys.add(_dateKey(t.startTime));
    }
    final list = keys.toList()..sort();
    return list;
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  bool _inSchedule(String talkId) => _scheduleTalkIds.contains(talkId);

  void _toggleSchedule(String talkId) {
    final wasIn = _scheduleTalkIds.contains(talkId);
    setState(() {
      if (wasIn) {
        _scheduleTalkIds.remove(talkId);
      } else {
        _scheduleTalkIds.add(talkId);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasIn
              ? 'Удалено из вашего расписания (заглушка)'
              : 'Добавлено в ваше расписание (заглушка)',
        ),
      ),
    );
  }

  List<({UiSection section, List<UiTalk> talks})> _groupedForDay(String? dayKey) {
    return UiMockData.sections.map((section) {
      var ts = UiMockData.talks
          .where(
            (t) =>
                t.sectionId == section.id && t.status == UiTalkStatus.ready,
          )
          .toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
      if (dayKey != null) {
        ts = ts.where((t) => _dateKey(t.startTime) == dayKey).toList();
      }
      return (section: section, talks: ts);
    }).where((g) => g.talks.isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    final dateKeys = _uniqueDateKeys();
    final speakers = UiMockData.users.where((u) => u.role == UiRole.speaker);

    return RootShell(
      role: widget.role,
      title: 'Программа мероприятия',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Выберите доклады для посещения',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: 12),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: [
              const Tab(text: 'Все дни'),
              for (var i = 0; i < dateKeys.length; i++)
                Tab(text: 'День ${i + 1}'),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: (MediaQuery.sizeOf(context).height * 0.62).clamp(320.0, 900.0),
            child: TabBarView(
              controller: _tabController,
              children: [
                _ProgramTab(
                  grouped: _groupedForDay(null),
                  speakers: speakers.toList(),
                  inSchedule: _inSchedule,
                  onToggle: _toggleSchedule,
                  role: widget.role,
                ),
                for (final dk in dateKeys)
                  _ProgramTab(
                    grouped: _groupedForDay(dk),
                    speakers: speakers.toList(),
                    inSchedule: _inSchedule,
                    onToggle: _toggleSchedule,
                    role: widget.role,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgramTab extends StatelessWidget {
  final List<({UiSection section, List<UiTalk> talks})> grouped;
  final List<UiUser> speakers;
  final bool Function(String) inSchedule;
  final void Function(String) onToggle;
  final UiRole role;

  const _ProgramTab({
    required this.grouped,
    required this.speakers,
    required this.inSchedule,
    required this.onToggle,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    if (grouped.isEmpty) {
      return Center(
        child: Text(
          'Нет докладов в этот день',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.55),
              ),
        ),
      );
    }

    return ListView(
      children: [
        for (final g in grouped) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          g.section.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      UiBadge(
                        '${g.talks.length} докладов',
                        variant: UiBadgeVariant.outline,
                      ),
                    ],
                  ),
                  if (g.section.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      g.section.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  for (final talk in g.talks)
                    _TalkCard(
                      talk: talk,
                      speaker: speakers.where((u) => u.id == talk.speakerId).firstOrNull,
                      inSchedule: inSchedule(talk.id),
                      onToggle: () => onToggle(talk.id),
                      role: role,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _TalkCard extends StatelessWidget {
  final UiTalk talk;
  final UiUser? speaker;
  final bool inSchedule;
  final VoidCallback onToggle;
  final UiRole role;

  const _TalkCard({
    required this.talk,
    required this.speaker,
    required this.inSchedule,
    required this.onToggle,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.talkDetails,
              arguments: {'role': role, 'talkId': talk.id},
            ),
            child: Text(
              talk.title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    decorationColor:
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                  ),
            ),
          ),
          if (talk.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              talk.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.65),
                  ),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 14,
            runSpacing: 8,
            children: [
              if (speaker != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_outline, size: 16, color: Theme.of(context).hintColor),
                    const SizedBox(width: 4),
                    Text(speaker!.name),
                  ],
                ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 14, color: Theme.of(context).hintColor),
                  const SizedBox(width: 4),
                  Text(_formatMonthDay(talk.startTime)),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.schedule, size: 16, color: Theme.of(context).hintColor),
                  const SizedBox(width: 4),
                  Text('${_formatTime(talk.startTime)} (${talk.durationMin} мин)'),
                ],
              ),
              if (talk.room != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.place_outlined, size: 16, color: Theme.of(context).hintColor),
                    const SizedBox(width: 4),
                    Text(talk.room!),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onToggle,
            icon: Icon(inSchedule ? Icons.check_circle : Icons.circle_outlined, size: 18),
            label: Text(inSchedule ? 'В моём расписании' : 'Буду'),
            style: inSchedule
                ? OutlinedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

String _formatTime(DateTime d) {
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  return '$hh:$mm';
}

String _formatMonthDay(DateTime d) {
  const months = [
    'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
    'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря',
  ];
  return '${d.day} ${months[d.month - 1]}';
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}
