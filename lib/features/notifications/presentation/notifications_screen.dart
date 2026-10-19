import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_strings.dart';
import '../../../core/l10n/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text.dart';
import '../../../shared/widgets/appear.dart';
import '../../../shared/widgets/async_states.dart';
import '../../../shared/widgets/icon_bubble.dart';
import '../../../shared/widgets/page_header.dart';
import '../../../shared/widgets/pressable_scale.dart';
import '../data/notifications_repository.dart';
import '../providers/notifications_providers.dart';
import '../../../shared/models/app_notification.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final items = ref.watch(notificationsListProvider);

    return Scaffold(
      body: Column(
        children: [
          PageHeader(
            title: strings.t('notifications.title'),
          ),
          Expanded(
            child: items.when(
        loading: () => LoadingState(message: strings.t('state.loading')),
        error: (error, _) => ErrorState(
          message: errorMessageFor(
            error,
            strings.t('state.offline'),
            strings.t('state.error'),
          ),
          retryLabel: strings.t('state.retry'),
          onRetry: () => ref.invalidate(notificationsListProvider),
        ),
        data: (notifications) {
          if (notifications.isEmpty) {
            return EmptyState(
              title: strings.t('notifications.empty'),
              icon: Icons.notifications_none_rounded,
            );
          }
          final hasUnread = notifications.any((item) => item.isUnread);
          return Column(
            children: [
              if (hasUnread)
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: () async {
                      await ref
                          .read(notificationsRepositoryProvider)
                          .markAllRead();
                      ref.invalidate(notificationsListProvider);
                    },
                    child: Text(strings.t('notifications.mark_all')),
                  ),
                ),
              Expanded(
                child: RefreshIndicator(
            onRefresh: () => ref.refresh(notificationsListProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: notifications.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = notifications[index];
                return Appear.stagger(
                  index: index,
                  child: PressableScale(
                    onTap: () => _open(context, ref, item),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: item.isUnread
                            ? AppColors.primarySoft
                            : AppColors.white,
                        borderRadius: BorderRadius.circular(AppSpacing.radius),
                        border: Border.all(
                          color: item.isUnread
                              ? AppColors.primaryMuted
                              : AppColors.line,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconBubble(
                            icon: item.isUnread
                                ? Icons.notifications_active_rounded
                                : Icons.notifications_none_rounded,
                            color: item.isUnread
                                ? AppColors.primary
                                : AppColors.muted,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _title(context, item, strings),
                                        style: AppText.title,
                                      ),
                                    ),
                                    if (item.isUnread)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(99),
                                        ),
                                        child: Text(
                                          strings.t('notifications.unread'),
                                          style: AppText.caption.copyWith(
                                            color: AppColors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                if (_body(context, item).isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    _body(context, item),
                                  style: AppText.bodyMuted,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
                ),
              ),
            ],
          );
        },
            ),
          ),
        ],
      ),
    );
  }
}

String _title(BuildContext context, AppNotification item, AppStrings strings) {
  final text = item.textTitle(Localizations.localeOf(context).languageCode);
  return text.isEmpty ? strings.t('notifications.title') : text;
}

String _body(BuildContext context, AppNotification item) {
  return item.textBody(Localizations.localeOf(context).languageCode);
}

Future<void> _open(BuildContext context, WidgetRef ref, AppNotification item) async {
  final id = item.targetId;
  final path = item.targetType == 'trip' && id != null ? '/trips/$id' : null;
  if (item.isUnread) {
    await ref.read(notificationsRepositoryProvider).markRead(item.id);
    ref.invalidate(notificationsListProvider);
  }
  if (path != null && context.mounted) {
    context.push(path);
  }
}
