import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kinder_world/core/constants/app_constants.dart';
import 'package:kinder_world/core/localization/app_localizations.dart';
import 'package:kinder_world/core/providers/auth_controller.dart';
import 'package:kinder_world/core/providers/avatar_picker_provider.dart';
import 'package:kinder_world/core/providers/child_session_controller.dart';
import 'package:kinder_world/core/providers/theme_provider.dart';
import 'package:kinder_world/core/theme/theme_palette.dart';
import 'package:kinder_world/core/theme/app_colors.dart';
import 'package:kinder_world/core/widgets/avatar_view.dart';
import 'package:kinder_world/core/widgets/child_header.dart';
import 'package:kinder_world/core/widgets/picture_password_row.dart';
import 'package:kinder_world/app.dart';

// ==========================================
// 1. Child Profile Screen (Main Screen)
// ==========================================

class ChildProfileScreen extends ConsumerWidget {
  const ChildProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final child = ref.watch(currentChildProvider);
    final childName = (child?.name.isNotEmpty ?? false) ? child!.name : child?.id;

    if (child == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.child_care_outlined,
                    size: 80,
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noChildSelected,
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: AppConstants.fontSize,
                      color: colors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/child/login'),
                    child: Text(l10n.login),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/child/home');
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Center(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const SettingsAvatarSelectionScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(60),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colors.primary,
                        width: 4,
                      ),
                      color: colors.primary.withValues(alpha: 0.2),
                    ),
                    child: AvatarView(
                      avatarId: child.avatar,
                      avatarPath: child.avatarPath,
                      radius: 56,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Hello, ${childName ?? ''}',
                style: textTheme.headlineSmall?.copyWith(
                  fontSize: AppConstants.largeFontSize * 1.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                l10n.levelExplorer(child.level),
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: AppConstants.fontSize,
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem(context, '${child.xp}', l10n.xp, AppColors.xpColor, Icons.star),
                  _buildStatItem(context, '${child.streak}', l10n.streak, AppColors.streakColor, Icons.local_fire_department),
                  _buildStatItem(context, '${child.activitiesCompleted}', l10n.activities, AppColors.success, Icons.check_circle),
                ],
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(20),
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
                    Text(
                      l10n.yourProgress,
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: AppConstants.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildProgressBar(context, l10n.xpToLevel(child.level + 1), child.xpProgress / 1000, AppColors.xpColor, '${child.xpProgress}/1000'),
                    const SizedBox(height: 16),
                    _buildProgressBar(context, l10n.dailyGoal, 0.7, AppColors.success, '7/10 ${l10n.activities}'),
                    const SizedBox(height: 16),
                    _buildProgressBar(context, l10n.weeklyChallenge, 0.5, AppColors.secondary, '3/6'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(20),
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
                    Text(
                      l10n.yourInterests,
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: AppConstants.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: child.interests.map((interest) => _buildInterestChip(context, interest)).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(20),
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
                    Text(
                      l10n.recentAchievements,
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: AppConstants.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildAchievementBadge(context, '🏆', 'First Quiz', 'Completed first quiz'),
                        _buildAchievementBadge(context, '🔥', '5 Day Streak', 'Keep it up!'),
                        _buildAchievementBadge(context, '⭐', 'Math Master', '100% accuracy'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ChildSettingsScreen()));
                },
                icon: const Icon(Icons.settings),
                label: Text(l10n.settings),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.surfaceContainerHighest,
                  foregroundColor: colors.onSurface,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label, Color color, IconData icon) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 25, color: color),
        ),
        const SizedBox(height: 8),
        Text(value, style: textTheme.titleMedium?.copyWith(fontSize: AppConstants.fontSize, fontWeight: FontWeight.bold)),
        Text(label, style: textTheme.bodySmall?.copyWith(fontSize: 12, color: colors.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context, String label, double value, Color color, String valueText) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: textTheme.bodyMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.w600)),
            Text(valueText, style: textTheme.bodySmall?.copyWith(fontSize: 12, color: colors.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: colors.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildInterestChip(BuildContext context, String interest) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(interest, style: textTheme.bodyMedium?.copyWith(fontSize: 14, color: colors.primary, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildAchievementBadge(BuildContext context, String emoji, String title, String description) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.xpColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
        ),
        const SizedBox(height: 8),
        Text(title, style: textTheme.bodySmall?.copyWith(fontSize: 12, fontWeight: FontWeight.bold)),
        Text(description, style: textTheme.labelSmall?.copyWith(fontSize: 10, color: colors.onSurfaceVariant), textAlign: TextAlign.center),
      ],
    );
  }
}

// ==========================================
// 2. Child Settings Screen
// ==========================================

class ChildSettingsScreen extends ConsumerStatefulWidget {
  const ChildSettingsScreen({super.key});

  @override
  ConsumerState<ChildSettingsScreen> createState() => _ChildSettingsScreenState();
}

class _ChildSettingsScreenState extends ConsumerState<ChildSettingsScreen> {
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  String _settingsQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: colors.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: colors.surface,
        title: Text(l10n.settings, style: TextStyle(fontWeight: FontWeight.bold, color: colors.onSurface)),
        centerTitle: true,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: colors.onSurface), onPressed: () => Navigator.of(context).pop()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const ChildHeader(compact: true),
          TextField(
            onChanged: (value) => setState(() => _settingsQuery = value),
            onSubmitted: (value) => _openSettingByQuery(value, locale),
            decoration: InputDecoration(
              hintText: 'Search settings...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: colors.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ..._buildFilteredSettings(context, locale),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              await ref.read(childSessionControllerProvider.notifier).endChildSession();
              await ref.read(authControllerProvider.notifier).logout();
              if (!context.mounted) return;
              context.go('/welcome');
            },
            icon: const Icon(Icons.logout),
            label: Text(l10n.logout),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: colors.onError,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFilteredSettings(BuildContext context, Locale locale) {
    final query = _settingsQuery.trim().toLowerCase();
    bool match(String text) =>
        query.isEmpty || text.toLowerCase().contains(query);

    final sections = <Widget>[];

    if (match('account') || match('edit profile') || match('change avatar')) {
      sections.add(_buildSectionHeader(context, "Account"));
      sections.add(const SizedBox(height: 10));
      sections.add(_buildSettingsCard(
        context,
        children: [
          _buildListTile(context, title: "Edit Profile", icon: Icons.person_outline, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsEditProfileScreen()));
          }),
          _buildDivider(),
          _buildListTile(context, title: "Change Avatar", icon: Icons.face_retouching_natural_outlined, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsAvatarSelectionScreen()));
          }),
        ],
      ));
      sections.add(const SizedBox(height: 30));
    }

    if (match('preferences') || match('sound') || match('music')) {
      sections.add(_buildSectionHeader(context, "Preferences"));
      sections.add(const SizedBox(height: 10));
      sections.add(_buildSettingsCard(
        context,
        children: [
          _buildSwitchTile(context, title: "Sound Effects", icon: Icons.volume_up_outlined, value: _soundEnabled, onChanged: (val) => setState(() => _soundEnabled = val)),
          _buildDivider(),
          _buildSwitchTile(context, title: "Background Music", icon: Icons.music_note_outlined, value: _musicEnabled, onChanged: (val) => setState(() => _musicEnabled = val)),
        ],
      ));
      sections.add(const SizedBox(height: 30));
    }

    if (match('app') || match('language') || match('themes') || match('about') || match('privacy')) {
      sections.add(_buildSectionHeader(context, "App Settings"));
      sections.add(const SizedBox(height: 10));
      sections.add(_buildSettingsCard(
        context,
        children: [
          _buildListTile(context, title: "Language", subtitle: _languageLabel(locale), icon: Icons.language_outlined, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsLanguageScreen()));
          }),
          _buildDivider(),
          _buildListTile(context, title: "Themes", subtitle: "Light & Calm", icon: Icons.color_lens_outlined, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ChildThemeScreen()));
          }),
          _buildDivider(),
          _buildListTile(context, title: "About Us", icon: Icons.info_outline, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsAboutUsScreen()));
          }),
          _buildDivider(),
          _buildListTile(context, title: "Privacy Policy", icon: Icons.lock_outline, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPrivacyPolicyScreen()));
          }),
        ],
      ));
      sections.add(const SizedBox(height: 30));
    }

    if (sections.isEmpty) {
      return [
        Center(
          child: Text(
            'No settings found',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ),
      ];
    }

    return sections;
  }

  void _openSettingByQuery(String value, Locale locale) {
    final query = value.trim().toLowerCase();
    if (query.isEmpty) return;

    if (query == 'edit profile' || query == 'profile') {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const SettingsEditProfileScreen()));
      return;
    }
    if (query == 'change avatar' || query == 'avatar') {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const SettingsAvatarSelectionScreen()));
      return;
    }
    if (query == 'language' ||
        query == _languageLabel(locale).toLowerCase() ||
        query == 'اللغة') {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const SettingsLanguageScreen()));
      return;
    }
    if (query == 'themes' || query == 'theme' || query == 'الثيمات' || query == 'المظهر') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ChildThemeScreen()),
      );
      return;
    }
    if (query == 'about' || query == 'about us' || query == 'حول' || query == 'من نحن') {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const SettingsAboutUsScreen()));
      return;
    }
    if (query == 'privacy' || query == 'privacy policy' || query == 'الخصوصية' || query == 'سياسة الخصوصية') {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const SettingsPrivacyPolicyScreen()));
      return;
    }
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
    );
  }

  Widget _buildSettingsCard(BuildContext context, {required List<Widget> children, Color? color}) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildListTile(BuildContext context, {required String title, String? subtitle, required IconData icon, Color? iconColor, Color? titleColor, VoidCallback? onTap}) {
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: (iconColor ?? colors.primary).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: iconColor ?? colors.primary, size: 24),
      ),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: titleColor)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: onTap != null ? Icon(Icons.arrow_forward_ios, size: 16, color: colors.onSurfaceVariant) : null,
      onTap: onTap,
    );
  }

  String _languageLabel(Locale locale) {
    switch (locale.languageCode) {
      case 'ar':
        return 'العربية؟';
      case 'en':
      default:
        return 'English (US)';
    }
  }

  Widget _buildSwitchTile(BuildContext context, {required String title, required IconData icon, required bool value, required ValueChanged<bool> onChanged}) {
    final colors = Theme.of(context).colorScheme;
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      secondary: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: colors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: colors.primary, size: 24),
      ),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
      value: value,
      onChanged: onChanged,
      activeColor: colors.primary,
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, indent: 70, endIndent: 20, color: Theme.of(context).colorScheme.outlineVariant);
  }
}

// ==========================================
// 3. NEW: Settings Language Selection Screen (Renamed to avoid conflict)
// ==========================================

class SettingsLanguageScreen extends ConsumerWidget {
  const SettingsLanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final colors = Theme.of(context).colorScheme;

    final languages = const [
      {'code': 'en', 'name': 'English (US)'},
      {'code': 'ar', 'name': 'العربية'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Language", style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: ChildHeader(compact: true),
          ),
          ...languages.map((language) {
            final isSelected = locale.languageCode == language['code'];
            return InkWell(
              onTap: () {
                ref.read(localeProvider.notifier).state =
                    Locale(language['code'] as String);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Language changed to ${language['name']}")),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.primary.withValues(alpha: 0.1)
                      : Colors.transparent,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Icon(Icons.flag, size: 20),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        language['name'] as String,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle, color: colors.primary),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ==========================================
// 4. NEW: Settings Avatar Selection Screen (Renamed)
// ==========================================

class SettingsAvatarSelectionScreen extends ConsumerStatefulWidget {
  const SettingsAvatarSelectionScreen({super.key});

  @override
  ConsumerState<SettingsAvatarSelectionScreen> createState() =>
      _SettingsAvatarSelectionScreenState();
}

class _SettingsAvatarSelectionScreenState
    extends ConsumerState<SettingsAvatarSelectionScreen> {
  String? _selectedAvatarPath;

  @override
  void initState() {
    super.initState();
    final child = ref.read(currentChildProvider);
    _selectedAvatarPath = child?.avatarPath.isNotEmpty == true
        ? child!.avatarPath
        : (child?.avatar.isNotEmpty == true ? child!.avatar : null);
  }

  @override
  Widget build(BuildContext context) {
    final avatars = ref.watch(availableAvatarsProvider);
    final child = ref.watch(currentChildProvider);
    final selectedPath = _selectedAvatarPath ??
        (avatars.isNotEmpty ? avatars.first : AppConstants.defaultChildAvatar);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose Avatar", style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        actions: [
          TextButton(
            onPressed: child == null
                ? null
                : () async {
                    final updated = child.copyWith(
                      avatar: selectedPath,
                      avatarPath: selectedPath,
                    );
                    await ref
                        .read(childSessionControllerProvider.notifier)
                        .updateChildProfile(updated);
                    if (!mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Avatar Saved")),
                    );
                  },
            child: const Text("Save", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: ChildHeader(compact: true),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1.0,
              ),
              itemCount: avatars.length,
              itemBuilder: (context, index) {
                final avatarPath = avatars[index];
                final isSelected = selectedPath == avatarPath;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedAvatarPath = avatarPath;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        width: 4,
                      ),
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[200],
                      backgroundImage: AssetImage(avatarPath),
                      onBackgroundImageError: (exception, stackTrace) {},
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 5. NEW: Settings Edit Profile Screen (Renamed)
// ==========================================

class SettingsEditProfileScreen extends ConsumerStatefulWidget {
  const SettingsEditProfileScreen({super.key});

  @override
  ConsumerState<SettingsEditProfileScreen> createState() =>
      _SettingsEditProfileScreenState();
}

class _SettingsEditProfileScreenState
    extends ConsumerState<SettingsEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  final List<String> _selectedPictures = [];

  @override
  void initState() {
    super.initState();
    final child = ref.read(currentChildProvider);
    _nameController = TextEditingController(text: child?.name ?? '');
    if (child != null && child.picturePassword.isNotEmpty) {
      _selectedPictures.addAll(child.picturePassword.take(3));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _togglePicture(String pictureId) {
    setState(() {
      if (_selectedPictures.contains(pictureId)) {
        _selectedPictures.remove(pictureId);
      } else if (_selectedPictures.length < 3) {
        _selectedPictures.add(pictureId);
      }
    });
  }

  Future<void> _saveProfile(BuildContext context) async {
    final child = ref.read(currentChildProvider);
    if (child == null) return;

    if (!_formKey.currentState!.validate()) return;
    if (_selectedPictures.length != 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select 3 pictures')),
      );
      return;
    }

    final newPassword = List<String>.from(_selectedPictures);
    final hasPasswordChange =
        child.picturePassword.length == 3 && child.picturePassword != newPassword;

    if (hasPasswordChange) {
      try {
        await ref.read(networkServiceProvider).post(
          '/auth/child/change-password',
          data: {
            'child_id': int.tryParse(child.id) ?? child.id,
            'name': child.name,
            'current_picture_password': child.picturePassword,
            'new_picture_password': newPassword,
          },
        );
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update picture password')),
        );
        return;
      }
    }

    final updated = child.copyWith(
      name: _nameController.text.trim(),
      picturePassword: newPassword,
    );

    await ref
        .read(childSessionControllerProvider.notifier)
        .updateChildProfile(updated);

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Profile Updated')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ChildHeader(compact: true),
              const SizedBox(height: 16),
              Row(
                children: [
                  AvatarView(
                    avatarId: ref.watch(currentChildProvider)?.avatar,
                    avatarPath: ref.watch(currentChildProvider)?.avatarPath,
                    radius: 24,
                    backgroundColor: Colors.transparent,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text("Change your avatar from Profile screen",
                        style: theme.textTheme.bodySmall),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text("Name", style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: "Enter your name",
                  filled: true,
                  fillColor: colors.surfaceContainerHighest,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Please enter a name';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text("Picture Password", style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text("Choose exactly 3 pictures", style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
              const SizedBox(height: 8),
              PicturePasswordRow(
                picturePassword: _selectedPictures,
                size: 24,
                showPlaceholders: true,
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: picturePasswordOptions.length,
                itemBuilder: (context, index) {
                  final option = picturePasswordOptions[index];
                  final isSelected = _selectedPictures.contains(option.id);
                  return InkWell(
                    onTap: () => _togglePicture(option.id),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? option.color.withValues(alpha: 0.2)
                            : colors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? option.color
                              : colors.surfaceContainerHighest,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        option.icon,
                        size: 28,
                        color: option.color,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _saveProfile(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text("Save Changes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 5.5 NEW: Child Theme Screen
// ==========================================

class ChildThemeScreen extends ConsumerWidget {
  const ChildThemeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettings = ref.watch(themeControllerProvider);
    final colors = Theme.of(context).colorScheme;

    final palettes = const [
      ThemePalettes.blue,
      ThemePalettes.green,
      ThemePalettes.sunset,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Themes', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const ChildHeader(compact: true),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.dark_mode),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Dark / Light'),
                ),
                Switch(
                  value: themeSettings.mode == ThemeMode.dark,
                  onChanged: (value) {
                    ref.read(themeControllerProvider.notifier).setMode(
                          value ? ThemeMode.dark : ThemeMode.light,
                        );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Choose a calm color',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          ...palettes.map((palette) {
            final isSelected = themeSettings.paletteId == palette.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => ref
                    .read(themeControllerProvider.notifier)
                    .setPalette(palette.id),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? colors.primary : colors.outlineVariant,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colors.shadow.withValues(alpha: 0.12),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: palette.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          palette.name,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle, color: colors.primary),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ==========================================
// 6. NEW: Settings About Us Screen
// ==========================================

class SettingsAboutUsScreen extends StatelessWidget {
  const SettingsAboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("About Us", style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const ChildHeader(compact: true),
            Center(child: Icon(Icons.child_care, size: 80, color: theme.colorScheme.primary)),
            const SizedBox(height: 20),
            Text("Kinder World App", style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("Version 1.0.0", style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
            const SizedBox(height: 30),
            Text(
              "Kinder World is a fun and educational application designed to help children learn through play. We focus on behavioral, educational, and skillful activities to provide a holistic learning experience.",
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            Text("Contact Us", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildContactRow(Icons.email, "support@kinderworld.com"),
            const SizedBox(height: 10),
            _buildContactRow(Icons.language, "www.kinderworld.com"),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600]),
        const SizedBox(width: 15),
        Text(text, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}

// ==========================================
// 7. NEW: Settings Privacy Policy Screen
// ==========================================

class SettingsPrivacyPolicyScreen extends StatelessWidget {
  const SettingsPrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy", style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ChildHeader(compact: true),
            Text("Last Updated: October 2023", style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
            const SizedBox(height: 20),
            Text("1. Introduction", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              "We respect your privacy and are committed to protecting it through our compliance with this policy.",
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 20),
            Text("2. Data Collection", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              "We collect information to provide better services to all our users. This includes personal details like name and avatar, and usage data to track progress.",
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 20),
            Text("3. Security", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              "We implement a variety of security measures to maintain the safety of your personal information.",
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
