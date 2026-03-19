import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ready_pro/blocs/auth/auth_bloc.dart';
import 'package:ready_pro/blocs/auth/auth_state.dart';
import 'package:ready_pro/blocs/talk/talk_bloc.dart';
import 'package:ready_pro/blocs/talk/talk_event.dart';
import 'package:ready_pro/blocs/talk/talk_state.dart';
import 'package:ready_pro/models/message.dart';
import 'package:ready_pro/models/feedback.dart' as model;
import 'package:ready_pro/core/enums.dart';

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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    UiBadge(
                      talk.status == TalkStatus.ready ? 'Готов' : 'В обработке',
                      variant: talk.status == TalkStatus.ready
                          ? UiBadgeVariant.defaultFill
                          : UiBadgeVariant.secondary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Секция ID: ${talk.sectionId}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
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
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final msg = state.messages[index];
                    final isMe = msg.userId == currentUserId;
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe 
                              ? Theme.of(context).colorScheme.primaryContainer 
                              : Theme.of(context).colorScheme.surfaceVariant,
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
                              'Пользователь: ${msg.userId}',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
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
                ),
                if (widget.role == UiRole.participant) ...[
                  const SizedBox(height: 32),
                  const Divider(),
                  Text(
                    'Оставить отзыв',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
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
              ],
            ),
          ),
        );
      },
    );
  }
}
