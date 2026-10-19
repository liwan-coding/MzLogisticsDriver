import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/providers/auth_controller.dart';
import '../../features/notifications/providers/notifications_providers.dart';
import '../api/api_client.dart';
import '../l10n/locale_controller.dart';
import '../router/app_router.dart';
import 'push_notifications.dart';

final pushCoordinatorProvider = Provider<void>((ref) {
  PushNotifications.bindRouter(ref.watch(routerProvider));
  PushNotifications.onForeground = () {
    try {
      ref.invalidate(notificationsListProvider);
    } catch (_) {}
  };
  ref.onDispose(() => PushNotifications.onForeground = null);

  String locale() => ref.read(localeControllerProvider).locale.languageCode;

  void sync(bool authenticated) {
    PushNotifications.setNavigationEnabled(authenticated);
    if (authenticated) {
      unawaited(PushNotifications.register(ref.read(apiClientProvider), locale()));
    }
  }

  ref.listen(authControllerProvider, (previous, next) {
    sync(next.asData?.value != null);
  });
  ref.listen(localeControllerProvider, (previous, next) {
    final signedIn = ref.read(authControllerProvider).asData?.value != null;
    if (!signedIn || previous?.locale == next.locale) return;
    unawaited(
      PushNotifications.register(
        ref.read(apiClientProvider),
        next.locale.languageCode,
      ),
    );
  });

  if (ref.read(authControllerProvider).asData?.value != null) {
    unawaited(Future<void>.microtask(() => sync(true)));
  }
});
