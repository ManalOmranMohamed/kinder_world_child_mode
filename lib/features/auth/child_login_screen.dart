import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kinder_world/core/theme/app_colors.dart';
import 'package:kinder_world/core/constants/app_constants.dart';
import 'package:kinder_world/core/models/child_profile.dart';
import 'package:kinder_world/core/providers/auth_controller.dart';
import 'package:kinder_world/core/providers/child_session_controller.dart';

class ChildLoginScreen extends ConsumerStatefulWidget {
  const ChildLoginScreen({super.key});

  @override
  ConsumerState<ChildLoginScreen> createState() => _ChildLoginScreenState();
}

class _ChildLoginScreenState extends ConsumerState<ChildLoginScreen> {
  final List<String> _selectedPictures = [];
  String? _selectedChildId;
  bool _isLoading = false;
  String? _error;

  // Available picture options for password
  final List<Map<String, dynamic>> _pictureOptions = [
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


  Future<void> _login() async {
    if (_selectedChildId == null || _selectedPictures.length != 3) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final childRepository = ref.read(childRepositoryProvider);
      final child = await childRepository.getChildProfile(_selectedChildId!);

      if (child == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _error = 'Child profile not found';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Child profile not found'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      // Verify picture password
      final storedPassword = child.picturePassword;
      if (storedPassword.length != 3 || 
          !_listsEqual(_selectedPictures, storedPassword)) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _error = 'Incorrect picture password';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Incorrect picture password. Please try again.'),
              backgroundColor: AppColors.error,
            ),
          );
          _selectedPictures.clear();
        }
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
        if (mounted) {
          setState(() {
            _isLoading = false;
            _error = authError ?? 'Authentication failed';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authError ?? 'Authentication failed. Please try again.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      // Start child session using child_session_controller
      final sessionController = ref.read(childSessionControllerProvider.notifier);
      final sessionSuccess = await sessionController.startChildSession(
        childId: _selectedChildId!,
        childProfile: child,
      );

      if (!sessionSuccess) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _error = 'Failed to start session';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to start session. Please try again.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      // Navigate to child home
      if (mounted) {
        context.go('/child/home');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Login failed. Please try again.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
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
    debugPrint('ChildLoginScreen build -> selectedChildId=$_selectedChildId');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.go('/select-user-type'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        const SizedBox(height: 20),
                        Text(
                          'Child Login',
                          style: TextStyle(
                            fontSize: AppConstants.largeFontSize * 1.2,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedChildId == null
                              ? 'Choose your profile to continue'
                              : 'Select your picture password',
                          style: TextStyle(
                            fontSize: AppConstants.fontSize,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Child Selection
                        if (_selectedChildId == null) _buildChildSelection(),
                        if (_selectedChildId != null) _buildPasswordSelection(),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.child_care_outlined,
              size: 80,
              color: AppColors.grey,
            ),
            const SizedBox(height: 24),
            Text(
              _error ?? 'No child profiles found',
              style: TextStyle(
                fontSize: AppConstants.fontSize,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                context.go('/select-user-type');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildSelection() {
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
          debugPrint('ChildLoginScreen: error fetching children -> ${snapshot.error}');
          return _buildErrorState();
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          debugPrint('ChildLoginScreen: no children found');
          return _buildErrorState();
        }

        final children = snapshot.data!;
        debugPrint('ChildLoginScreen: found ${children.length} children');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Your Profile:',
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
              children: children.map((child) => _buildChildCard(child)).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPasswordSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected child info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: FutureBuilder<ChildProfile?>(
            future: ref.read(childRepositoryProvider).getChildProfile(_selectedChildId!),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                final child = snapshot.data!;
                return Row(
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
                          child.name[0],
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
                            'Level ${child.level} • ${child.xp} XP',
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
                      onPressed: () {
                        setState(() {
                          _selectedChildId = null;
                          _selectedPictures.clear();
                        });
                      },
                    ),
                  ],
                );
              }
              return const SizedBox();
            },
          ),
        ),
        const SizedBox(height: 32),

        // Picture Password Selection
        Text(
          'Select Your Picture Password:',
          style: TextStyle(
            fontSize: AppConstants.fontSize,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),

        // Selected pictures display
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
            children: List.generate(3, (index) {
              final pictureId = _selectedPictures.length > index ? _selectedPictures[index] : null;
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
                  color: picture != null ? AppColors.primary.withOpacity(0.1) : AppColors.lightGrey,
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

        // Picture options grid
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
              onTap: () {
                setState(() {
                  if (_selectedPictures.length < 3 && !isSelected) {
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

        // Clear button
        if (_selectedPictures.isNotEmpty)
          Center(
            child: TextButton(
              onPressed: () {
                setState(() {
                  _selectedPictures.clear();
                });
              },
              child: const Text('Clear Selection'),
            ),
          ),

        const SizedBox(height: 24),

        // Login button
        SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton(
            onPressed: (_selectedPictures.length == 3 && !_isLoading) ? _login : null,
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
                    'Login',
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

  Widget _buildChildCard(ChildProfile child) {
    final isSelected = _selectedChildId == child.id;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedChildId = child.id;
          _selectedPictures.clear();
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.lightGrey,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.behavioral.withOpacity(0.2),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Center(
                child: Text(
                  child.name[0],
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
              '${child.age} years old',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            // Level indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.xpColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Level ${child.level}',
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