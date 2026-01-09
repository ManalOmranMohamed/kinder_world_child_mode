import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kinder_world/core/theme/app_colors.dart';
import 'package:kinder_world/core/constants/app_constants.dart';
import 'package:kinder_world/core/models/child_profile.dart';
import 'package:kinder_world/core/providers/auth_controller.dart';
import 'package:kinder_world/core/providers/child_session_controller.dart';
import 'package:kinder_world/core/localization/app_localizations.dart';
import 'package:kinder_world/core/repositories/child_repository.dart';

class ChildLoginScreen extends ConsumerStatefulWidget {
  const ChildLoginScreen({super.key});

  @override
  ConsumerState<ChildLoginScreen> createState() => _ChildLoginScreenState();
}

class _ChildLoginScreenState extends ConsumerState<ChildLoginScreen> {
  static const int _passwordLength = 3;
  static const bool _enableDemoLogin = true;

  final List<String> _selectedPictures = [];
  String? _selectedChildId;
  ChildProfile? _selectedChildProfile; // ✅ cache selected child (supports demo)
  bool _isLoading = false;
  String? _error;

  final List<Map<String, dynamic>> _pictureOptions = const [
    {'id': 'apple', 'icon': '🍎', 'name': 'Apple'},
    {'id': 'ball', 'icon': '⚽', 'name': 'Ball'},
    {'id': 'cat', 'icon': '🐱', 'name': 'Cat'},
    {'id': 'dog', 'icon': '🐶', 'name': 'Dog'},
    {'id': 'elephant', 'icon': '🐘', 'name': 'Elephant'},
    {'id': 'fish', 'icon': '🐠', 'name': 'Fish'},
    {'id': 'guitar', 'icon': '🎸', 'name': 'Guitar'},
    {'id': 'house', 'icon': '🏠', 'name': 'House'},
    {'id': 'icecream', 'icon': '🍦', 'name': 'Ice Cream'},
    {'id': 'jelly', 'icon': '🍇', 'name': 'Jelly'},
    {'id': 'kite', 'icon': '🪁', 'name': 'Kite'},
    {'id': 'lion', 'icon': '🦁', 'name': 'Lion'},
  ];

  void _showError(String message) {
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _error = message;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _resetSelection() {
    setState(() {
      _selectedChildId = null;
      _selectedChildProfile = null;
      _selectedPictures.clear();
      _error = null;
    });
  }

  ChildProfile _demoChild() {
    final now = DateTime.now();
    return ChildProfile(
      id: 'demo',
      name: 'Demo Kid',
      age: 7,
      avatar: 'default',
      interests: const ['games', 'music'],
      level: 1,
      xp: 120,
      streak: 0,
      favorites: const [],
      parentId: 'demo-parent',
      picturePassword: const ['apple', 'ball', 'cat'],
      createdAt: now,
      updatedAt: now,
      lastSession: null,
      totalTimeSpent: 0,
      activitiesCompleted: 0,
      currentMood: null,
      learningStyle: null,
      specialNeeds: null,
      accessibilityNeeds: null,
    );
  }

  Future<void> _login() async {
    final l10n = AppLocalizations.of(context)!;

    if (_selectedChildId == null || _selectedPictures.length != _passwordLength) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // ✅ Use cached profile if available (demo or normal)
      ChildProfile? child = _selectedChildProfile;

      // If not cached (rare), fetch it (except demo)
      if (child == null) {
        if (_selectedChildId == 'demo') {
          child = _demoChild();
        } else {
          final childRepository = ref.read(childRepositoryProvider);
          child = await childRepository.getChildProfile(_selectedChildId!);
        }
      }

      if (child == null) {
        _showError(l10n.childProfileNotFound);
        return;
      }

      // Verify picture password
      final storedPassword = child.picturePassword;
      final isValidPassword = storedPassword.length == _passwordLength &&
          _listsEqual(_selectedPictures, storedPassword);

      if (!isValidPassword) {
        _showError(l10n.incorrectPicturePassword);
        setState(() {
          _selectedPictures.clear();
        });
        return;
      }

      // Authenticate using auth_controller
      final authController = ref.read(authControllerProvider.notifier);
      final authSuccess = await authController.loginChild(
        childId: _selectedChildId!,
        picturePassword: _selectedPictures,
      );

      if (!authSuccess) {
        final authError = ref.read(authControllerProvider).error;
        _showError(authError ?? l10n.loginError);
        return;
      }

      // Start child session using child_session_controller
      final sessionController = ref.read(childSessionControllerProvider.notifier);
      final sessionSuccess = await sessionController.startChildSession(
        childId: _selectedChildId!,
        childProfile: child,
      );

      if (!sessionSuccess) {
        _showError(l10n.failedToStartSession);
        return;
      }

      if (mounted) {
        context.go('/child/home');
      }
    } catch (_) {
      _showError(l10n.loginError);
    }
  }

  bool _listsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: _isLoading ? null : () => context.go('/select-user-type'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              Text(
                l10n.childLogin,
                style: TextStyle(
                  fontSize: AppConstants.largeFontSize * 1.2,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _selectedChildId == null
                    ? l10n.chooseProfileToContinue
                    : l10n.selectPicturePassword,
                style: TextStyle(
                  fontSize: AppConstants.fontSize,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 40),

              if (_selectedChildId == null) _buildChildSelection(l10n),
              if (_selectedChildId != null) _buildPasswordSelection(l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(top: 32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.child_care_outlined,
            size: 80,
            color: AppColors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            _error ?? l10n.noChildProfilesFound,
            style: TextStyle(
              fontSize: AppConstants.fontSize,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 220,
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : () => context.go('/select-user-type'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(l10n.goBack),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildSelection(AppLocalizations l10n) {
    return FutureBuilder<List<ChildProfile>>(
      future: ref.read(childRepositoryProvider).getAllChildProfiles(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorState(l10n);
        }

        final repoChildren = snapshot.data ?? const <ChildProfile>[];

        final children = (repoChildren.isEmpty && _enableDemoLogin)
            ? <ChildProfile>[_demoChild()]
            : repoChildren;

        if (children.isEmpty) {
          return _buildErrorState(l10n);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.chooseYourProfile,
              style: TextStyle(
                fontSize: AppConstants.fontSize,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: children.map((child) => _buildChildCard(child, l10n)).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPasswordSelection(AppLocalizations l10n) {
    // ✅ Use cached profile for UI (works with demo)
    final child = _selectedChildProfile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: child == null
              ? const SizedBox()
              : Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          child.name.isNotEmpty ? child.name[0] : '?',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            child.name,
                            style: TextStyle(
                              fontSize: AppConstants.fontSize,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            l10n.levelXp(child.level, child.xp),
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textSecondary),
                      onPressed: _isLoading ? null : _resetSelection,
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 32),

        Text(
          l10n.selectPicturePassword,
          style: TextStyle(
            fontSize: AppConstants.fontSize,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),

        Text(
          '${_selectedPictures.length}/$_passwordLength',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),

        Container(
          height: 80,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.lightGrey),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_passwordLength, (index) {
              final pictureId =
                  _selectedPictures.length > index ? _selectedPictures[index] : null;
              final picture = pictureId != null
                  ? _pictureOptions.firstWhere(
                      (p) => p['id'] == pictureId,
                      orElse: () => {'icon': '', 'name': ''},
                    )
                  : null;

              return Container(
                width: 56,
                height: 56,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: picture != null
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: picture != null ? AppColors.primary : AppColors.grey,
                    width: 2,
                  ),
                ),
                child: picture != null && picture['icon'] != null
                    ? Center(
                        child: Text(
                          picture['icon'] as String,
                          style: const TextStyle(fontSize: 28),
                        ),
                      )
                    : null,
              );
            }),
          ),
        ),
        const SizedBox(height: 24),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: _pictureOptions.length,
          itemBuilder: (context, index) {
            final picture = _pictureOptions[index];
            final isSelected = _selectedPictures.contains(picture['id']);

            return InkWell(
              onTap: _isLoading
                  ? null
                  : () {
                      setState(() {
                        if (_selectedPictures.length < _passwordLength && !isSelected) {
                          _selectedPictures.add(picture['id'] as String);
                        } else if (isSelected) {
                          _selectedPictures.remove(picture['id']);
                        }
                      });
                    },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.2)
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.lightGrey,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      picture['icon'] as String,
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      picture['name'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 32),

        if (_selectedPictures.isNotEmpty)
          Center(
            child: TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      setState(() {
                        _selectedPictures.clear();
                      });
                    },
              child: Text(l10n.clearSelection),
            ),
          ),

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton(
            onPressed:
                (_selectedPictures.length == _passwordLength && !_isLoading) ? _login : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.behavioral,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: AppColors.white)
                : Text(
                    l10n.login,
                    style: TextStyle(
                      fontSize: AppConstants.fontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildChildCard(ChildProfile child, AppLocalizations l10n) {
    final isSelected = _selectedChildId == child.id;

    return InkWell(
      onTap: _isLoading
          ? null
          : () {
              setState(() {
                _selectedChildId = child.id;
                _selectedChildProfile = child; // ✅ cache selected child
                _selectedPictures.clear();
                _error = null;
              });
            },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.lightGrey,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.behavioral.withOpacity(0.2),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Center(
                child: Text(
                  child.name.isNotEmpty ? child.name[0] : '?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.behavioral,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              child.name,
              style: TextStyle(
                fontSize: AppConstants.fontSize,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              l10n.yearsOld(child.age),
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.xpColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${l10n.level} ${child.level}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.xpColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
