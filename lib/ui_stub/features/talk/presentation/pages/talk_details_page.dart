import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ready_pro/blocs/auth/auth_bloc.dart';
import 'package:ready_pro/blocs/auth/auth_state.dart';
import 'package:ready_pro/blocs/talk/talk_bloc.dart';
import 'package:ready_pro/blocs/talk/talk_event.dart';
import 'package:ready_pro/blocs/talk/talk_state.dart';
import 'package:ready_pro/models/message.dart';
import 'package:ready_pro/models/talk.dart';
import 'package:ready_pro/models/feedback.dart' as model;
import 'package:ready_pro/core/enums.dart';
import 'package:ready_pro/app/layout/app_breakpoints.dart';

import '../../../../shared/mock/ui_models.dart';
import '../../../../shared/presentation/layout/root_shell.dart';
import '../../../../shared/presentation/widgets/ui_badge.dart';

class TalkDetailsPage extends StatefulWidget {
  final UiRole role;
  final String talkId;

  const TalkDetailsPage({super.key, required this.role, required this.talkId});

  @override
  State<TalkDetailsPage> createState() => _TalkDetailsPageState();
}

class _TalkDetailsPageState extends State<TalkDetailsPage> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<TalkBloc>().add(FetchTalkDetails(widget.talkId));
  }

  void _sendMessage(String? currentUserId) {
    if (_messageController.text.trim().isEmpty || currentUserId == null) return;

    final message = Message(
      id: '',
      talkId: widget.talkId,
      userId: currentUserId,
      content: _messageController.text.trim(),
      createdAt: DateTime.now(), // Добавлено обязательное поле
    );

    context.read<TalkBloc>().add(SendMessageRequested(message));
    _messageController.clear();
  }

  /// Имя из вложенного профиля сообщения (Supabase `profiles(*)`), иначе id.
  static String _messageAuthorDisplayName(Message msg) {
    final p = msg.user;
    if (p != null) {
      final name = p.fullName.trim();
      if (name.isNotEmpty) return name;
      final email = p.email.trim();
      if (email.isNotEmpty) return email;
    }
    return msg.userId;
  }

  /// Название секции из состояния блока, иначе id (если загрузка секции не удалась).
  static String _sectionDisplayName(TalkState state, Talk talk) {
    final name = state.section?.name.trim();
    if (name != null && name.isNotEmpty) return name;
    return talk.sectionId;
  }

  List<Widget> _scrollableDetailChildren({
    required BuildContext context,
    required TalkState state,
    required Talk talk,
    String? currentUserId,
  }) {
    return [
      SizedBox(
        width: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UiBadge(
              talk.status == TalkStatus.ready ? 'Готов' : 'В обработке',
              variant: talk.status == TalkStatus.ready
                  ? UiBadgeVariant.defaultFill
                  : UiBadgeVariant.secondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Секция: ${_sectionDisplayName(state, talk)}',
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Text(
        talk.description ?? 'Описание отсутствует',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      const SizedBox(height: 24),
      const Divider(),
      Text(
        'Вопросы и обсуждение',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 12),
      for (final msg in state.messages)
        Align(
          alignment: msg.userId == currentUserId
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: msg.userId == currentUserId
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  msg.content,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  _messageAuthorDisplayName(msg),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ),
      if (widget.role == UiRole.participant) ...[
        const SizedBox(height: 32),
        const Divider(),
        Text(
          'Оставить отзыв',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 0,
          runSpacing: 0,
          children: List.generate(5, (index) {
            return IconButton(
              onPressed: () {
                if (currentUserId != null) {
                  final feedback = model.Feedback(
                    id: '',
                    talkId: widget.talkId,
                    userId: currentUserId,
                    rating: index + 1,
                    comment: '',
                  );
                  context.read<TalkBloc>().add(SubmitFeedbackRequested(feedback));
                }
              },
              icon: const Icon(Icons.star_border),
            );
          }),
        ),
      ],
    ];
  }

  Widget _messageInputBar(BuildContext context, String? currentUserId) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextField(
            controller: _messageController,
            minLines: 1,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Задать вопрос...',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () => _sendMessage(currentUserId),
          icon: const Icon(Icons.send),
          color: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TalkBloc, TalkState>(
      builder: (context, state) {
        if (state.isLoading) {
          return RootShell(
            role: widget.role,
            title: 'Доклад',
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final talk = state.talk;
        if (talk == null) {
          return RootShell(
            role: widget.role,
            title: 'Доклад',
            child: const Center(child: Text('Доклад не найден')),
          );
        }

        final authState = context.read<AuthBloc>().state;
        final currentUserId = authState is AuthAuthenticated ? authState.user.id : null;

        return RootShell(
          role: widget.role,
          title: talk.title,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final items = _scrollableDetailChildren(
                context: context,
                state: state,
                talk: talk,
                currentUserId: currentUserId,
              );
              final listView = ListView(
                padding: EdgeInsets.zero,
                children: items,
              );

              /// На широком экране — тот же приём, что с `Column`, но ось **Row**:
              /// слева `Expanded` + прокрутка, справа колонка с вводом.
              final useRowLayout =
                  constraints.maxWidth >= AppBreakpoints.expanded;

              if (useRowLayout) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: listView),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 320,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: _messageInputBar(context, currentUserId),
                        ),
                      ),
                    ),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: listView),
                  const SizedBox(height: 16),
                  _messageInputBar(context, currentUserId),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
