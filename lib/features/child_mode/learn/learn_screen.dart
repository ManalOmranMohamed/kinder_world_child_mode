import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kinder_world/core/constants/app_constants.dart';
import 'package:kinder_world/core/models/activity.dart';
import 'package:kinder_world/core/providers/activity_filter_controller.dart';
import 'package:kinder_world/core/providers/content_controller.dart';
import 'package:kinder_world/core/theme/app_colors.dart';

class LearnScreen extends ConsumerStatefulWidget {
  const LearnScreen({super.key});

  @override
  ConsumerState<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends ConsumerState<LearnScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();

    // Load activities when screen loads.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(contentControllerProvider.notifier).loadAllActivities();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contentState = ref.watch(contentControllerProvider);
    final filteredActivities = ref.watch(filteredActivitiesProvider);
    final filters = ref.watch(activityFilterControllerProvider);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _slideAnimation.value,
          child: child,
        );
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Learn',
                          style: TextStyle(
                            fontSize: AppConstants.largeFontSize * 1.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _showFiltersSheet(context),
                          icon: Icon(
                            Icons.filter_list,
                            color: filters.hasActiveFilters
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                          tooltip: 'Filters',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Choose what you want to learn today!',
                      style: TextStyle(
                        fontSize: AppConstants.fontSize,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Aspect Tabs
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: ActivityAspects.all.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final aspect = ActivityAspects.all[index];
                    final isSelected = aspect == filters.selectedAspect;
                    final color = _getAspectColor(aspect);

                    return InkWell(
                      onTap: () {
                        ref
                            .read(activityFilterControllerProvider.notifier)
                            .selectAspect(aspect);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? color : AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? color : AppColors.lightGrey,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getAspectIcon(aspect),
                              size: 20,
                              color: isSelected ? AppColors.white : color,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              ActivityAspects.getDisplayName(aspect),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight:
                                    isSelected ? FontWeight.w600 : FontWeight.normal,
                                color: isSelected
                                    ? AppColors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Activities Grid
              Expanded(
                child: contentState.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : contentState.error != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: AppColors.error,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  contentState.error!,
                                  style: const TextStyle(
                                    fontSize: AppConstants.fontSize,
                                    color: AppColors.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    ref
                                        .read(contentControllerProvider.notifier)
                                        .loadAllActivities();
                                  },
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : filteredActivities.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.school_outlined,
                                      size: 64,
                                      color: AppColors.grey,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'No activities available',
                                      style: TextStyle(
                                        fontSize: AppConstants.fontSize,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Try adjusting your filters.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : GridView.builder(
                                padding: const EdgeInsets.all(16),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.85,
                                ),
                                itemCount: filteredActivities.length,
                                itemBuilder: (context, index) {
                                  final activity = filteredActivities[index];
                                  return _buildActivityCard(activity);
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFiltersSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final filters = ref.watch(activityFilterControllerProvider);
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Filters',
                            style: TextStyle(
                              fontSize: AppConstants.largeFontSize,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              ref
                                  .read(activityFilterControllerProvider.notifier)
                                  .clearFilters();
                            },
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Category',
                        style: TextStyle(
                          fontSize: AppConstants.fontSize,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('All'),
                            selected: filters.selectedCategory == null,
                            onSelected: (_) {
                              ref
                                  .read(activityFilterControllerProvider.notifier)
                                  .selectCategory(null);
                            },
                          ),
                          ...ActivityCategories.all.map((category) {
                            return ChoiceChip(
                              label: Text(
                                ActivityCategories.getDisplayName(category),
                              ),
                              selected: filters.selectedCategory == category,
                              onSelected: (_) {
                                ref
                                    .read(activityFilterControllerProvider.notifier)
                                    .selectCategory(category);
                              },
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Difficulty',
                        style: TextStyle(
                          fontSize: AppConstants.fontSize,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('All'),
                            selected: filters.selectedDifficulty == null,
                            onSelected: (_) {
                              ref
                                  .read(activityFilterControllerProvider.notifier)
                                  .selectDifficulty(null);
                            },
                          ),
                          ...DifficultyLevels.all.map((difficulty) {
                            return ChoiceChip(
                              label: Text(
                                DifficultyLevels.getDisplayName(difficulty),
                              ),
                              selected: filters.selectedDifficulty == difficulty,
                              onSelected: (_) {
                                ref
                                    .read(activityFilterControllerProvider.notifier)
                                    .selectDifficulty(difficulty);
                              },
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Apply Filters'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildActivityCard(Activity activity) {
    return InkWell(
      onTap: () => context.go('/child/learn/lesson/${activity.id}'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            SizedBox(
              height: 110,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  image: activity.thumbnailUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(activity.thumbnailUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: activity.thumbnailUrl.isEmpty
                    ? Center(
                        child: Icon(
                          _getAspectIcon(activity.aspect),
                          size: 40,
                          color: _getAspectColor(activity.aspect),
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 8),

            // Title
            Text(
              activity.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: AppConstants.fontSize,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),

            // Meta row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      activity.estimatedTime,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: AppColors.xpColor),
                    const SizedBox(width: 4),
                    Text(
                      '${activity.xpReward} XP',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getAspectColor(String aspect) {
    switch (aspect) {
      case ActivityAspects.behavioral:
        return AppColors.behavioral;
      case ActivityAspects.skillful:
        return AppColors.skillful;
      case ActivityAspects.educational:
        return AppColors.educational;
      case ActivityAspects.entertaining:
        return AppColors.entertaining;
      default:
        return AppColors.primary;
    }
  }

  IconData _getAspectIcon(String aspect) {
    switch (aspect) {
      case ActivityAspects.behavioral:
        return Icons.emoji_people;
      case ActivityAspects.skillful:
        return Icons.handyman;
      case ActivityAspects.educational:
        return Icons.school;
      case ActivityAspects.entertaining:
        return Icons.videogame_asset;
      default:
        return Icons.extension;
    }
  }
}
