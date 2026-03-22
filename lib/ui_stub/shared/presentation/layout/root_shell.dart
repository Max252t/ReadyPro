import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ready_pro/blocs/auth/auth_bloc.dart';
import 'package:ready_pro/blocs/auth/auth_event.dart';
import 'package:ready_pro/blocs/auth/auth_state.dart';
import 'package:ready_pro/models/user.dart';

import '../../../../app/routes.dart';
import '../../../../app/widgets/theme_toggle_button.dart';
import '../../mock/ui_models.dart';
import '../../route_args.dart';

typedef _Navigate = void Function(String routeName, {Map<String, dynamic>? extraArgs});

class RootShell extends StatelessWidget {
  final UiRole role;
  final Widget child;
  final String title;
  final List<Widget>? actions;

  const RootShell({
    super.key,
    required this.role,
    required this.title,
    required this.child,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is AuthUnauthenticated) return const SizedBox.shrink();
    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    final user = authState.user;
    final navLinks = _navLinksForRole(role);
    final routeName = ModalRoute.of(context)?.settings.name ?? '';

    final currentArgs = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final eventId = eventIdFromArgs(currentArgs);

    final eventLinks = navLinks.where((l) => l.isEventSpecific).toList();
    final globalLinks = navLinks.where((l) => !l.isEventSpecific).toList();

    final hasEvent = eventId != null && eventId.isNotEmpty;
    final isEventSpecificRoute = eventLinks.any((l) => l.routeName == routeName);
    
    // TabBar показываем ТОЛЬКО если: есть мероприятие И мы на событийном экране
    final showTabBar = hasEvent && isEventSpecificRoute && eventLinks.isNotEmpty;

    final nav = _NavContent(
      user: user,
      links: globalLinks,
      selectedRouteName: routeName,
      onNavigate: (route, {extraArgs}) {
        final Map<String, dynamic> nextArgs = {'role': role};
        if (eventId != null) nextArgs['eventId'] = eventId;
        if (extraArgs != null) nextArgs.addAll(extraArgs);
        
        Navigator.pushReplacementNamed(context, route, arguments: nextArgs);
      },
      onOpenProfile: () => Navigator.pushReplacementNamed(
        context,
        AppRoutes.profile,
        arguments: {'role': role, if (eventId != null) 'eventId': eventId},
      ),
      onLogout: () => context.read<AuthBloc>().add(AuthSignOutRequested()),
    );

    return Scaffold(
      appBar: AppBar(
        // Если показываем TabBar, то заголовок - название экрана, иначе общее название
        title: Text(showTabBar ? title : (title.isNotEmpty ? title : 'ReadyPro')),
        actions: [
          if (actions != null) ...actions!,
          const SizedBox(width: 8),
        ],
        bottom: showTabBar 
          ? TabBarWidget(
              links: eventLinks,
              selectedRouteName: routeName,
              onTap: (route) {
                Navigator.pushReplacementNamed(
                  context,
                  route,
                  arguments: {'role': role, 'eventId': eventId},
                );
              },
            )
          : null,
      ),
      drawer: Drawer(child: nav),
      body: SafeArea(
        child: _PageFrame(
          child: (isEventSpecificRoute && !hasEvent) 
            ? _buildNoEventStub(context) 
            : child,
        ),
      ),
    );
  }

  Widget _buildNoEventStub(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.event_note, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Мероприятие не выбрано', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Выберите мероприятие из списка, чтобы продолжить', textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pushReplacementNamed(
              context, 
              AppRoutes.allEvents, 
              arguments: {'role': role},
            ),
            child: const Text('Перейти к списку мероприятий'),
          ),
        ],
      ),
    );
  }
}

class TabBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final List<_NavLink> links;
  final String selectedRouteName;
  final Function(String) onTap;

  const TabBarWidget({super.key, required this.links, required this.selectedRouteName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).appBarTheme.backgroundColor,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: links.map((link) {
            final isSelected = selectedRouteName == link.routeName;
            return InkWell(
              onTap: () => onTap(link.routeName),
              child: Container(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width / (links.length > 4 ? 4 : links.length),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    link.label,
                    style: TextStyle(
                      color: isSelected ? Theme.of(context).primaryColor : null,
                      fontWeight: isSelected ? FontWeight.bold : null,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(48);
}

class _PageFrame extends StatelessWidget {
  final Widget child;

  const _PageFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}

class _NavContent extends StatelessWidget {
  final Profile user;
  final List<_NavLink> links;
  final String selectedRouteName;
  final _Navigate onNavigate;
  final VoidCallback onOpenProfile;
  final VoidCallback onLogout;

  const _NavContent({
    required this.user,
    required this.links,
    required this.selectedRouteName,
    required this.onNavigate,
    required this.onOpenProfile,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UserAccountsDrawerHeader(
          decoration: BoxDecoration(color: Theme.of(context).primaryColor),
          accountName: Text(user.fullName),
          accountEmail: Text(user.email),
          currentAccountPicture: CircleAvatar(
            backgroundColor: Colors.white,
            backgroundImage: (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                ? NetworkImage(user.avatarUrl!)
                : null,
            child: (user.avatarUrl == null || user.avatarUrl!.isEmpty) ? Icon(Icons.person, color: Theme.of(context).primaryColor, size: 40) : null,
          ),
          otherAccountsPictures: const [
            ThemeToggleButton(),
          ],
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              for (final link in links)
                ListTile(
                  leading: Icon(link.icon),
                  title: Text(link.label),
                  selected: selectedRouteName == link.routeName,
                  onTap: () => onNavigate(link.routeName, extraArgs: link.extraArgs),
                ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.account_circle_outlined),
                title: const Text('Профиль'),
                selected: selectedRouteName == AppRoutes.profile,
                onTap: onOpenProfile,
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Выйти'),
                onTap: onLogout,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NavLink {
  final String routeName;
  final IconData icon;
  final String label;
  final bool isEventSpecific;
  final Map<String, dynamic>? extraArgs;

  const _NavLink({
    required this.routeName,
    required this.icon,
    required this.label,
    this.isEventSpecific = true,
    this.extraArgs,
  });
}

List<_NavLink> _navLinksForRole(UiRole role) {
  final List<_NavLink> links = [];

  // Вкладки мероприятия (TabBar)
  if (role == UiRole.organizer) {
    links.addAll([
      const _NavLink(routeName: AppRoutes.organizerDashboard, icon: Icons.dashboard, label: 'Дашборд'),
      const _NavLink(routeName: AppRoutes.organizerSections, icon: Icons.groups, label: 'Секции'),
      const _NavLink(routeName: AppRoutes.organizerTasks, icon: Icons.checklist, label: 'Задачи'),
      const _NavLink(routeName: AppRoutes.organizerSchedule, icon: Icons.calendar_month, label: 'Наполнение'),
      const _NavLink(routeName: AppRoutes.eventTeam, icon: Icons.badge, label: 'Команда'),
    ]);
  } else if (role == UiRole.curator) {
    links.addAll([
      const _NavLink(routeName: AppRoutes.curatorDashboard, icon: Icons.dashboard, label: 'Дашборд'),
      const _NavLink(routeName: AppRoutes.curatorReports, icon: Icons.description, label: 'Отчеты'),
      const _NavLink(routeName: AppRoutes.eventTeam, icon: Icons.badge, label: 'Команда'),
    ]);
  } else if (role == UiRole.speaker) {
    links.addAll([
      const _NavLink(routeName: AppRoutes.speakerTalks, icon: Icons.mic, label: 'Доклады'),
      const _NavLink(routeName: AppRoutes.eventTeam, icon: Icons.badge, label: 'Команда'),
    ]);
  } else if (role == UiRole.participant) {
    links.addAll([
      const _NavLink(routeName: AppRoutes.participantProgram, icon: Icons.slideshow, label: 'Программа'),
      const _NavLink(routeName: AppRoutes.eventTeam, icon: Icons.badge, label: 'Команда'),
    ]);
  }

  // Глобальные ссылки (Drawer)
  links.add(
    const _NavLink(
      routeName: AppRoutes.allEvents, 
      icon: Icons.event, 
      label: 'Все мероприятия', 
      isEventSpecific: false,
    )
  );

  links.add(
    const _NavLink(
      routeName: AppRoutes.participantMySchedule, 
      icon: Icons.calendar_today, 
      label: 'Моё расписание', 
      isEventSpecific: false
    )
  );

  return links;
}
