import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kinder_world/core/localization/app_localizations.dart';
import 'package:kinder_world/core/subscription/plan_info.dart';
import 'package:kinder_world/core/theme/app_colors.dart';
import 'package:kinder_world/core/providers/plan_provider.dart';
import 'package:kinder_world/core/widgets/plan_status_banner.dart';
import 'package:kinder_world/core/widgets/premium_badge.dart';
import 'package:kinder_world/core/widgets/premium_section_upsell.dart';

class ParentNotificationsScreen extends ConsumerWidget {
  const ParentNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final notifications = _getMockNotifications(l10n);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final plan =
        ref.watch(planInfoProvider).asData?.value ?? PlanInfo.fromTier(PlanTier.free);
    final isSmartLocked = !plan.hasAiInsights;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: Text(
          l10n.notifications,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Mark all as read
            },
            child: Text(
              l10n.markAllRead,
              style: textTheme.bodyMedium?.copyWith(color: colors.primary),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: PlanStatusBanner(margin: EdgeInsets.zero),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.outlineVariant),
                  boxShadow: [
                    BoxShadow(
                      color: colors.shadow.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.recommendedForYou,
                            style: textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (isSmartLocked) const PremiumBadge(),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.planAiInsightsPro,
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    if (isSmartLocked)
                      PremiumSectionUpsell(
                        title: l10n.planFeatureInPremium,
                        description: l10n.planAiInsightsPro,
                        buttonLabel: l10n.upgradeNow,
                        showBadge: false,
                        padding: const EdgeInsets.all(12),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                itemCount: notifications.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return _NotificationCard(
                    notification: notification,
                    onTap: () {
                      // Handle notification tap
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getMockNotifications(AppLocalizations l10n) {
    return [
      {
        'id': '1',
        'title': l10n.dailyGoal,
        'message': l10n.notificationDailyGoal('Lina', 3),
        'time': '2 ${l10n.hoursAgo}',
        'type': 'achievement',
        'isRead': false,
        'childName': 'Lina',
      },
      {
        'id': '2',
        'title': l10n.screenTime,
        'message': l10n.notificationScreenTime('Omar', 2),
        'time': '4 ${l10n.hoursAgo}',
        'type': 'warning',
        'isRead': false,
        'childName': 'Omar',
      },
      {
        'id': '3',
        'title': l10n.achievements,
        'message': l10n.notificationAchievement('Lina', 'Math Master'),
        'time': '1 ${l10n.daysAgo}',
        'type': 'achievement',
        'isRead': true,
        'childName': 'Lina',
      },
      {
        'id': '4',
        'title': l10n.weeklyProgress,
        'message': l10n.notificationWeeklyReport,
        'time': '2 ${l10n.daysAgo}',
        'type': 'report',
        'isRead': true,
        'childName': l10n.childProfiles,
      },
      {
        'id': '5',
        'title': l10n.learningProgress,
        'message': l10n.notificationMilestone('Omar', 50),
        'time': '3 ${l10n.daysAgo}',
        'type': 'milestone',
        'isRead': true,
        'childName': 'Omar',
      },
      {
        'id': '6',
        'title': l10n.recommendedForYou,
        'message': l10n.notificationRecommendation('Lina'),
        'time': '1 ${l10n.week}',
        'type': 'recommendation',
        'isRead': true,
        'childName': 'Lina',
      },
    ];
  }
}

class _NotificationCard extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onTap;
  
  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: notification['isRead']
              ? colors.surface
              : colors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification['isRead']
                ? colors.outlineVariant
                : colors.primary.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon based on type
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color:
                    _getTypeColor(notification['type']).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                _getTypeIcon(notification['type']),
                size: 24,
                color: _getTypeColor(notification['type']),
              ),
            ),
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification['title'],
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: notification['isRead']
                                ? FontWeight.normal
                                : FontWeight.bold,
                          ),
                        ),
                      ),
                      if (!notification['isRead'])
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  Text(
                    notification['message'],
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      Text(
                        notification['childName'],
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '-',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        notification['time'],
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'achievement':
        return AppColors.success;
      case 'warning':
        return AppColors.error;
      case 'report':
        return AppColors.info;
      case 'milestone':
        return AppColors.xpColor;
      case 'recommendation':
        return AppColors.secondary;
      default:
        return AppColors.primary;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'achievement':
        return Icons.emoji_events;
      case 'warning':
        return Icons.warning;
      case 'report':
        return Icons.analytics;
      case 'milestone':
        return Icons.flag;
      case 'recommendation':
        return Icons.thumb_up;
      default:
        return Icons.notifications;
    }
  }
}
