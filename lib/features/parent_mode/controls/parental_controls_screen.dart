import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kinder_world/core/providers/parental_controls_controller.dart';
import 'package:kinder_world/core/theme/app_colors.dart';
import 'package:kinder_world/core/constants/app_constants.dart';

class ParentalControlsScreen extends ConsumerWidget {
  const ParentalControlsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controlsState = ref.watch(parentalControlsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Parental Controls'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Content Restrictions & Screen Time',
                style: TextStyle(
                  fontSize: AppConstants.largeFontSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage what your child can access and for how long',
                style: TextStyle(
                  fontSize: AppConstants.fontSize,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 40),
              
              _buildControlSection(
                'Screen Time Limits',
                Icons.timer,
                [
                 _buildToggleSetting(
                     'Daily Limit',
                    controlsState.dailyLimitEnabled,
                    (value) => ref
                      .read(parentalControlsProvider.notifier)
                      .setDailyLimitEnabled(value),
                  ),
                  _buildSliderSetting(
                    'Hours per day',
                    controlsState.hoursPerDay,
                    0,
                    6,
                    controlsState.dailyLimitEnabled
                        ? (value) => ref
                            .read(parentalControlsProvider.notifier)
                            .setHoursPerDay(value)
                        : null,
                  ),
                  _buildToggleSetting(
                    'Break Reminders',
                    controlsState.breakRemindersEnabled,
                    (value) => ref
                        .read(parentalControlsProvider.notifier)
                        .setBreakRemindersEnabled(value),
                  ),

                ],
              ),
              
              const SizedBox(height: 24),
              
              _buildControlSection(
                'Content Filtering',
                Icons.filter_list,
                [_buildToggleSetting(
                    'Age-Appropriate Only',
                    controlsState.ageAppropriateOnly,
                    (value) => ref
                        .read(parentalControlsProvider.notifier)
                        .setAgeAppropriateOnly(value),
                  ),
                  _buildToggleSetting(
                    'Block Educational Content',
                    controlsState.blockEducationalContent,
                    (value) => ref
                        .read(parentalControlsProvider.notifier)
                        .setBlockEducationalContent(value),
                  ),
                  _buildToggleSetting(
                    'Require Approval',
                    controlsState.requireApproval,
                    (value) => ref
                        .read(parentalControlsProvider.notifier)
                        .setRequireApproval(value),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              _buildControlSection(
                'Time Restrictions',
                Icons.access_time,
                [_buildToggleSetting(
                    'Sleep Mode',
                    controlsState.sleepModeEnabled,
                    (value) => ref
                        .read(parentalControlsProvider.notifier)
                        .setSleepModeEnabled(value),
                  ),
                  _buildTimeSetting(
                    context,
                    'Bedtime',
                    controlsState.bedtime,
                    controlsState.sleepModeEnabled
                        ? (value) => ref
                            .read(parentalControlsProvider.notifier)
                            .setBedtime(value)
                        : null,
                  ),
                  _buildTimeSetting(
                    context,
                    'Wake Time',
                    controlsState.wakeTime,
                    controlsState.sleepModeEnabled
                        ? (value) => ref
                            .read(parentalControlsProvider.notifier)
                            .setWakeTime(value)
                        : null,
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // Emergency Controls
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency Controls',
                      style: TextStyle(
                        fontSize: AppConstants.fontSize,
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement emergency lock 
                        showDialog<void>(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Lock App Now'),
                              content: const Text(
                                'The app will be locked immediately for the child profile.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('App locked for child mode.'),
                                      ),
                                    );
                                  },
                                  child: const Text('Lock'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.lock),
                      label: const Text('Lock App Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: AppColors.white,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlSection(String title, IconData icon, List<Widget> controls) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
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
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: AppConstants.fontSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...controls,
        ],
      ),
    );
  }

  Widget _buildToggleSetting(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: AppConstants.fontSize,
              color: AppColors.textPrimary,
            ),
          ),
          Switch(
            value: value,
                       onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSetting(
    String title,
    double value,
    double min,
    double max,
    ValueChanged<double>? onChanged,
  ) {    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: AppConstants.fontSize,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: value,
            min: min,
            max: max,
                        onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSetting(
    BuildContext context,
    String title,
    TimeOfDay time,
    ValueChanged<TimeOfDay>? onSelected,
  ) {    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: AppConstants.fontSize,
              color: AppColors.textPrimary,
            ),
          ),
          TextButton(
           
            onPressed: onSelected == null
                ? null
                : () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: time,
                    );

                    if (picked != null) {
                      onSelected(picked);
                    }
                  },
            child: Text(
                            MaterialLocalizations.of(context).formatTimeOfDay(time),
              style: TextStyle(
                fontSize: AppConstants.fontSize,
                color: onSelected == null ? AppColors.grey : AppColors.primary,              ),
            ),
          ),
        ],
      ),
    );
  }
}