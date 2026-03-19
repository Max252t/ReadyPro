import 'package:flutter/material.dart';

import '../../../../../app/routes.dart';
import '../../../../shared/mock/ui_mock_data.dart';
import '../../../../shared/mock/ui_models.dart';
import '../../../../shared/presentation/layout/root_shell.dart';
import '../../../../shared/presentation/widgets/ui_badge.dart';

class TalkDetailsPage extends StatefulWidget {
  final UiRole role;
  final String talkId;

  const TalkDetailsPage({
    super.key,
    required this.role,
    required this.talkId,
  });

  @override
  State<TalkDetailsPage> createState() => _TalkDetailsPageState();
}

class _TalkDetailsPageState extends State<TalkDetailsPage> {
  final _commentCtrl = TextEditingController();
  final _feedbackCommentCtrl = TextEditingController();
  final List<UiComment> _localComments = [];

  int _rating = 5;
  bool _showFeedbackForm = false;
  int? _submittedRating;
  String? _submittedFeedbackText;

  @override
  void dispose() {
    _commentCtrl.dispose();
    _feedbackCommentCtrl.dispose();
    super.dispose();
  }

  void _goBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.participantProgram,
        arguments: {'role': widget.role},
      );
    }
  }

  void _sendComment(UiTalk talk, UiUser user) {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _localComments.add(
        UiComment(
          id: 'local_${DateTime.now().millisecondsSinceEpoch}',
          talkId: talk.id,
          userId: user.id,
          message: text,
          createdAt: DateTime.now(),
        ),
      );
      _commentCtrl.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Вопрос отправлен (заглушка)')),
    );
  }

  void _submitFeedback(UiUser user, List<UiFeedback> existingForUser) {
    if (existingForUser.isNotEmpty || _submittedRating != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Вы уже оставили отзыв на этот доклад (заглушка)'),
        ),
      );
      return;
    }
    setState(() {
      _submittedRating = _rating;
      _submittedFeedbackText = _feedbackCommentCtrl.text.trim();
      _showFeedbackForm = false;
      _feedbackCommentCtrl.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Спасибо за отзыв! (заглушка)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final talk = UiMockData.talks.where((t) => t.id == widget.talkId).firstOrNull;
    final user = UiMockData.userForRole(widget.role);

    if (talk == null) {
      return RootShell(
        role: widget.role,
        title: 'Доклад',
        child: Column(
          children: [
            Text(
              'Доклад не найден',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.65),
                  ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.pushReplacementNamed(
                context,
                AppRoutes.participantProgram,
                arguments: {'role': widget.role},
              ),
              child: const Text('Вернуться к программе'),
            ),
          ],
        ),
      );
    }

    final section =
        UiMockData.sections.where((s) => s.id == talk.sectionId).firstOrNull;
    final speaker =
        UiMockData.users.where((u) => u.id == talk.speakerId).firstOrNull;

    final baseComments = UiMockData.comments.where((c) => c.talkId == talk.id);
    final allComments = [...baseComments, ..._localComments]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final talkFeedback =
        UiMockData.feedback.where((f) => f.talkId == talk.id).toList();
    final myExisting =
        talkFeedback.where((f) => f.userId == user.id).toList();

    final avg = _averageRating(talkFeedback, _submittedRating);

    final isCurator =
        section?.curatorId != null && section!.curatorId == user.id;

    return RootShell(
      role: widget.role,
      title: 'Детали доклада',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: () => _goBack(context),
            icon: const Icon(Icons.arrow_back, size: 18),
            label: const Text('Назад к программе'),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              talk.title,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            if (section != null) ...[
                              const SizedBox(height: 8),
                              UiBadge(section.name, variant: UiBadgeVariant.outline),
                            ],
                          ],
                        ),
                      ),
                      UiBadge(
                        talk.status == UiTalkStatus.ready ? 'Готов' : 'Черновик',
                        variant: talk.status == UiTalkStatus.ready
                            ? UiBadgeVariant.defaultFill
                            : UiBadgeVariant.secondary,
                      ),
                    ],
                  ),
                  if (talk.description.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      talk.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.7),
                          ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      if (speaker != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_outline, size: 18, color: Theme.of(context).hintColor),
                            const SizedBox(width: 6),
                            Text(speaker.name),
                          ],
                        ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.schedule, size: 18, color: Theme.of(context).hintColor),
                          const SizedBox(width: 6),
                          Text(
                            '${_formatDateLong(talk.startTime)}, ${_formatTime(talk.startTime)} (${talk.durationMin} мин)',
                          ),
                        ],
                      ),
                      if (talk.room != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.place_outlined, size: 18, color: Theme.of(context).hintColor),
                            const SizedBox(width: 6),
                            Text(talk.room!),
                          ],
                        ),
                    ],
                  ),
                  if (avg != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber.shade600, size: 22),
                        const SizedBox(width: 6),
                        Text(
                          avg,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${talkFeedback.length} отзывов)',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6),
                              ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Вопросы и обсуждение',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const Spacer(),
                      UiBadge('${allComments.length}', variant: UiBadgeVariant.outline),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 360),
                    child: Scrollbar(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          if (allComments.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Text(
                                  'Пока нет вопросов. Будьте первым!',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.55),
                                      ),
                                ),
                              ),
                            )
                          else
                            for (final c in allComments)
                              _CommentTile(
                                comment: c,
                                speakerId: talk.speakerId,
                                curatorId: section?.curatorId,
                              ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 28),
                  Text(
                    'Ваш вопрос',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentCtrl,
                          decoration: const InputDecoration(
                            hintText: 'Задайте вопрос спикеру...',
                          ),
                          onSubmitted: (_) => _sendComment(talk, user),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(48, 48),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () => _sendComment(talk, user),
                        child: const Icon(Icons.send, size: 20),
                      ),
                    ],
                  ),
                  if (isCurator)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Вы куратор этой секции и можете отвечать на вопросы (заглушка)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.55),
                            ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star_outline, size: 20, color: Colors.amber.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Обратная связь',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (myExisting.isNotEmpty)
                    _ExistingFeedbackCard(feedback: myExisting.first)
                  else if (_submittedRating != null)
                    _SubmittedFeedbackCard(
                      rating: _submittedRating!,
                      text: _submittedFeedbackText,
                    )
                  else if (_showFeedbackForm)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Оценка', style: Theme.of(context).textTheme.labelLarge),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            for (var i = 1; i <= 5; i++)
                              IconButton(
                                onPressed: () => setState(() => _rating = i),
                                icon: Icon(
                                  i <= _rating ? Icons.star : Icons.star_border,
                                  color: Colors.amber.shade600,
                                  size: 32,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Комментарий (необязательно)',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _feedbackCommentCtrl,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: 'Поделитесь своим мнением о докладе...',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            FilledButton(
                              onPressed: () => _submitFeedback(user, myExisting),
                              child: const Text('Отправить отзыв'),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: () => setState(() => _showFeedbackForm = false),
                              child: const Text('Отмена'),
                            ),
                          ],
                        ),
                      ],
                    )
                  else
                    FilledButton(
                      onPressed: () => setState(() => _showFeedbackForm = true),
                      child: const Text('Оставить отзыв'),
                    ),
                  if (talkFeedback.where((f) => (f.comment ?? '').isNotEmpty).isNotEmpty) ...[
                    const Divider(height: 28),
                    Text(
                      'Отзывы участников',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 10),
                    for (final f in talkFeedback.where((x) => (x.comment ?? '').isNotEmpty))
                      _PublicFeedbackTile(feedback: f),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final UiComment comment;
  final String speakerId;
  final String? curatorId;

  const _CommentTile({
    required this.comment,
    required this.speakerId,
    required this.curatorId,
  });

  @override
  Widget build(BuildContext context) {
    final author =
        UiMockData.users.where((u) => u.id == comment.userId).firstOrNull;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  author?.name ?? 'Пользователь',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Text(
                _formatDateTime(comment.createdAt),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.55),
                    ),
              ),
            ],
          ),
          if (comment.userId == speakerId)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: UiBadge('Спикер', variant: UiBadgeVariant.secondary),
            ),
          if (curatorId != null && comment.userId == curatorId)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: UiBadge('Куратор', variant: UiBadgeVariant.secondary),
            ),
          const SizedBox(height: 6),
          Text(comment.message, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ExistingFeedbackCard extends StatelessWidget {
  final UiFeedback feedback;

  const _ExistingFeedbackCard({required this.feedback});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ваша оценка',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 1; i <= 5; i++)
                Icon(
                  i <= feedback.rating ? Icons.star : Icons.star_border,
                  color: Colors.amber.shade600,
                  size: 22,
                ),
            ],
          ),
          if ((feedback.comment ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              feedback.comment!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SubmittedFeedbackCard extends StatelessWidget {
  final int rating;
  final String? text;

  const _SubmittedFeedbackCard({required this.rating, this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ваша оценка',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 1; i <= 5; i++)
                Icon(
                  i <= rating ? Icons.star : Icons.star_border,
                  color: Colors.amber.shade600,
                  size: 22,
                ),
            ],
          ),
          if (text != null && text!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(text!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

class _PublicFeedbackTile extends StatelessWidget {
  final UiFeedback feedback;

  const _PublicFeedbackTile({required this.feedback});

  @override
  Widget build(BuildContext context) {
    final author =
        UiMockData.users.where((u) => u.id == feedback.userId).firstOrNull;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                author?.name ?? 'Участник',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  for (var i = 1; i <= 5; i++)
                    Icon(
                      i <= feedback.rating ? Icons.star : Icons.star_border,
                      color: Colors.amber.shade600,
                      size: 14,
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            feedback.comment ?? '',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
          ),
        ],
      ),
    );
  }
}

String? _averageRating(List<UiFeedback> list, int? extraRating) {
  if (list.isEmpty && extraRating == null) return null;
  var sum = 0;
  var n = 0;
  for (final f in list) {
    sum += f.rating;
    n++;
  }
  if (extraRating != null) {
    sum += extraRating;
    n++;
  }
  if (n == 0) return null;
  return (sum / n).toStringAsFixed(1);
}

String _formatTime(DateTime d) {
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  return '$hh:$mm';
}

String _formatDateLong(DateTime d) {
  const months = [
    'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
    'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

String _formatDateTime(DateTime d) {
  const months = [
    'янв', 'фев', 'мар', 'апр', 'май', 'июн',
    'июл', 'авг', 'сен', 'окт', 'ноя', 'дек',
  ];
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  return '${d.day} ${months[d.month - 1]}, $hh:$mm';
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}
