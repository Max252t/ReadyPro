import 'mock/ui_models.dart';

UiRole uiRoleFromArgs(Object? args, {UiRole fallback = UiRole.participant}) {
  if (args is! Map) return fallback;
  final r = args['role'];
  if (r is UiRole) return r;
  return fallback;
}

String talkIdFromArgs(Object? args, {String fallback = 'talk1'}) {
  if (args is! Map) return fallback;
  final id = args['talkId'];
  if (id is String && id.isNotEmpty) return id;
  return fallback;
}
