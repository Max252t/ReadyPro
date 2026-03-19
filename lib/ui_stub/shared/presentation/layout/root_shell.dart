import 'package:flutter/material.dart';

import '../../../../app/routes.dart';
import '../../../../app/widgets/theme_toggle_button.dart';
import '../../mock/ui_mock_data.dart';
import '../../mock/ui_models.dart';

class RootShell extends StatelessWidget {
  final UiRole role;
  final Widget child;
  final String title;

  const RootShell({
    super.key,
    required this.role,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final user = UiMockData.userForRole(role);
    final navLinks = _navLinksForRole(role);
    final routeName = ModalRoute.of(context)?.settings.name ?? '';
    final isDesktop = MediaQuery.sizeOf(context).width >= 900;

    final nav = _NavContent(
      user: user,
      links: navLinks,
      selectedRouteName: routeName,
      onNavigate: (route) => Navigator.pushReplacementNamed(
        context,
        route,
        arguments: {'role': role},
      ),
      onOpenProfile: () => Navigator.pushReplacementNamed(
        context,
        AppRoutes.profile,
        arguments: {'role': role},
      ),
    );

    return Scaffold(
      appBar: isDesktop
          ? null
          : AppBar(
              title: const Text('Хакатон 2026'),
              actions: const [
                ThemeToggleButton(),
                SizedBox(width: 4),
              ],
            ),
      drawer: isDesktop ? null : Drawer(child: nav),
      body: SafeArea(
        child: Row(
          children: [
            if (isDesktop)
              SizedBox(
                width: 280,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                  ),
                  child: nav,
                ),
              ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isDesktop ? 32 : 16,
                  16,
                  isDesktop ? 32 : 16,
                  24,
                ),
                child: _PageFrame(
                  title: title,
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageFrame extends StatelessWidget {
  final String title;
  final Widget child;

  const _PageFrame({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'Кликабельный UI (заглушки) • без логики',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(
                      alpha: 0.6,
                    ),
              ),
        ),
        const SizedBox(height: 20),
        child,
      ],
    );
  }
}

typedef _Navigate = void Function(String routeName);

class _NavContent extends StatelessWidget {
  final UiUser user;
  final List<_NavLink> links;
  final String selectedRouteName;
  final _Navigate onNavigate;
  final VoidCallback onOpenProfile;

  const _NavContent({
    required this.user,
    required this.links,
    required this.selectedRouteName,
    required this.onNavigate,
    required this.onOpenProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Хакатон 2026',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor:
                        Theme.of(context).colorScheme.primary.withValues(
                              alpha: 0.12,
                            ),
                    child: Icon(
                      _roleIcon(user.role),
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Text(
                          _roleLabel(user.role),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Divider(height: 1, color: Theme.of(context).dividerColor),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              for (final link in links)
                _NavTile(
                  icon: link.icon,
                  label: link.label,
                  selected: selectedRouteName == link.routeName,
                  onTap: () => onNavigate(link.routeName),
                ),
            ],
          ),
        ),
        Divider(height: 1, color: Theme.of(context).dividerColor),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                child: Row(
                  children: [
                    Text(
                      'Тема',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.65),
                          ),
                    ),
                    const Spacer(),
                    const ThemeToggleButton(),
                  ],
                ),
              ),
              _NavTile(
                icon: Icons.account_circle_outlined,
                label: 'Профиль',
                selected: selectedRouteName == AppRoutes.profile,
                onTap: onOpenProfile,
              ),
              const SizedBox(height: 4),
              TextButton.icon(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (_) => false,
                ),
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Выйти'),
                style: TextButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  minimumSize: const Size.fromHeight(44),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = selected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8);
    final bg = selected
        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.10)
        : Colors.transparent;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: fg),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: fg,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavLink {
  final String routeName;
  final IconData icon;
  final String label;

  const _NavLink({
    required this.routeName,
    required this.icon,
    required this.label,
  });
}

List<_NavLink> _navLinksForRole(UiRole role) {
  switch (role) {
    case UiRole.organizer:
      return const [
        _NavLink(
          routeName: AppRoutes.organizerDashboard,
          icon: Icons.dashboard_outlined,
          label: 'Дашборд',
        ),
        _NavLink(
          routeName: AppRoutes.organizerSections,
          icon: Icons.groups_outlined,
          label: 'Секции',
        ),
        _NavLink(
          routeName: AppRoutes.organizerTasks,
          icon: Icons.checklist_outlined,
          label: 'Задачи',
        ),
        _NavLink(
          routeName: AppRoutes.organizerSchedule,
          icon: Icons.calendar_month_outlined,
          label: 'Программа',
        ),
        _NavLink(
          routeName: AppRoutes.participantProgram,
          icon: Icons.slideshow_outlined,
          label: 'Расписание',
        ),
      ];
    case UiRole.curator:
      return const [
        _NavLink(
          routeName: AppRoutes.curatorDashboard,
          icon: Icons.dashboard_outlined,
          label: 'Дашборд',
        ),
        _NavLink(
          routeName: AppRoutes.curatorReports,
          icon: Icons.description_outlined,
          label: 'Отчеты',
        ),
        _NavLink(
          routeName: AppRoutes.participantProgram,
          icon: Icons.slideshow_outlined,
          label: 'Программа',
        ),
      ];
    case UiRole.speaker:
      return const [
        _NavLink(
          routeName: AppRoutes.speakerTalks,
          icon: Icons.mic_none_outlined,
          label: 'Мои доклады',
        ),
        _NavLink(
          routeName: AppRoutes.participantProgram,
          icon: Icons.calendar_month_outlined,
          label: 'Программа',
        ),
      ];
    case UiRole.participant:
      return const [
        _NavLink(
          routeName: AppRoutes.participantProgram,
          icon: Icons.slideshow_outlined,
          label: 'Программа',
        ),
        _NavLink(
          routeName: AppRoutes.participantMySchedule,
          icon: Icons.calendar_today_outlined,
          label: 'Моё расписание',
        ),
      ];
  }
}

String _roleLabel(UiRole role) {
  switch (role) {
    case UiRole.organizer:
      return 'Организатор';
    case UiRole.curator:
      return 'Куратор';
    case UiRole.speaker:
      return 'Спикер';
    case UiRole.participant:
      return 'Участник';
  }
}

IconData _roleIcon(UiRole role) {
  switch (role) {
    case UiRole.organizer:
      return Icons.event_available_outlined;
    case UiRole.curator:
      return Icons.fact_check_outlined;
    case UiRole.speaker:
      return Icons.record_voice_over_outlined;
    case UiRole.participant:
      return Icons.badge_outlined;
  }
}

