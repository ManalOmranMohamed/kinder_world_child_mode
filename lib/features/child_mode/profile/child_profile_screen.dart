import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kinder_world/core/constants/app_constants.dart';
import 'package:kinder_world/core/localization/app_localizations.dart';
import 'package:kinder_world/core/providers/auth_controller.dart';
import 'package:kinder_world/core/providers/child_session_controller.dart';
import 'package:kinder_world/core/theme/app_colors.dart';
import 'package:kinder_world/core/widgets/avatar_view.dart';

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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Center(
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
              const SizedBox(height: 20),
              Text(
                child.name,
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
              OutlinedButton.icon(
                onPressed: () async {
                  await ref.read(childSessionControllerProvider.notifier).endChildSession();
                  await ref.read(authControllerProvider.notifier).logout();
                  if (!context.mounted) return;
                  context.go('/welcome');
                },
                icon: const Icon(Icons.logout),
                label: Text(l10n.logout),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
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

class ChildSettingsScreen extends StatefulWidget {
  const ChildSettingsScreen({super.key});

  @override
  State<ChildSettingsScreen> createState() => _ChildSettingsScreenState();
}

class _ChildSettingsScreenState extends State<ChildSettingsScreen> {
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

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
          // 1. Account Section
          _buildSectionHeader(context, "Account"),
          const SizedBox(height: 10),
          _buildSettingsCard(
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
          ),
          const SizedBox(height: 30),

          // 2. Preferences Section
          _buildSectionHeader(context, "Preferences"),
          const SizedBox(height: 10),
          _buildSettingsCard(
            context,
            children: [
              _buildSwitchTile(context, title: "Sound Effects", icon: Icons.volume_up_outlined, value: _soundEnabled, onChanged: (val) => setState(() => _soundEnabled = val)),
              _buildDivider(),
              _buildSwitchTile(context, title: "Background Music", icon: Icons.music_note_outlined, value: _musicEnabled, onChanged: (val) => setState(() => _musicEnabled = val)),
              _buildDivider(),
              _buildSwitchTile(context, title: "Notifications", icon: Icons.notifications_outlined, value: _notificationsEnabled, onChanged: (val) => setState(() => _notificationsEnabled = val)),
            ],
          ),
          const SizedBox(height: 30),

          // 3. App Section
          _buildSectionHeader(context, "App Settings"),
          const SizedBox(height: 10),
          _buildSettingsCard(
            context,
            children: [
              _buildListTile(context, title: "Language", subtitle: "English (US)", icon: Icons.language_outlined, onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsLanguageScreen()));
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
          ),
          const SizedBox(height: 30),

          // 4. Danger Zone
          _buildSettingsCard(
            context,
            color: Colors.red[50],
            children: [
              _buildListTile(context, title: "Reset Progress", icon: Icons.refresh, iconColor: Colors.red, titleColor: Colors.red, onTap: () {
                _showResetDialog(context);
              }),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
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

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Reset Progress?"),
        content: const Text("This will delete all your XP, levels, and achievements. This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Progress Reset")));
            },
            child: const Text("Reset", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 3. NEW: Settings Language Selection Screen (Renamed to avoid conflict)
// ==========================================

class SettingsLanguageScreen extends StatefulWidget {
  const SettingsLanguageScreen({super.key});

  @override
  State<SettingsLanguageScreen> createState() => _SettingsLanguageScreenState();
}

class _SettingsLanguageScreenState extends State<SettingsLanguageScreen> {
  String _selectedLang = 'English (US)'; // Mock current language

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Language", style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(
        children: [
          _buildLanguageTile(context, 'English (US)', 'assets/icons/flag_us.png', 'English (US)'),
          _buildLanguageTile(context, 'العربية', 'assets/icons/flag_eg.png', 'العربية'),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(BuildContext context, String title, String flagPath, String value) {
    final isSelected = _selectedLang == value;
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedLang = value;
        });
        // Mock saving logic
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Language changed to $title")));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary.withValues(alpha: 0.1) : Colors.transparent,
        ),
        child: Row(
          children: [
            // Placeholder for Flag Image
            Container(
              width: 40,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(5),
              ),
              child: Icon(Icons.flag, size: 20),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
            ),
            if (isSelected) Icon(Icons.check_circle, color: colors.primary),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 4. NEW: Settings Avatar Selection Screen (Renamed)
// ==========================================

class SettingsAvatarSelectionScreen extends StatefulWidget {
  const SettingsAvatarSelectionScreen({super.key});

  @override
  State<SettingsAvatarSelectionScreen> createState() => _SettingsAvatarSelectionScreenState();
}

class _SettingsAvatarSelectionScreenState extends State<SettingsAvatarSelectionScreen> {
  int _selectedAvatarIndex = 0;

  final List<String> _mockAvatars = List.generate(8, (index) => 'assets/images/avatar_${index + 1}.png');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose Avatar", style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Avatar Saved")));
            },
            child: const Text("Save", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: 1.0,
        ),
        itemCount: _mockAvatars.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedAvatarIndex = index;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _selectedAvatarIndex == index ? Theme.of(context).colorScheme.primary : Colors.transparent,
                  width: 4,
                ),
              ),
              child: CircleAvatar(
                backgroundColor: Colors.grey[200],
                backgroundImage: AssetImage(_mockAvatars[index]),
                onBackgroundImageError: (exception, stackTrace) {},
              ),
            ),
          );
        },
      ),
    );
  }
}

// ==========================================
// 5. NEW: Settings Edit Profile Screen (Renamed)
// ==========================================

class SettingsEditProfileScreen extends StatefulWidget {
  const SettingsEditProfileScreen({super.key});

  @override
  State<SettingsEditProfileScreen> createState() => _SettingsEditProfileScreenState();
}

class _SettingsEditProfileScreenState extends State<SettingsEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController(text: "Ava"); // Mock initial value

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
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
                  if (value == null || value.isEmpty) return 'Please enter a name';
                  return null;
                },
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile Updated")));
                    }
                  },
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