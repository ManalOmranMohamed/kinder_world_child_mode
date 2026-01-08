import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kinder_world/core/theme/app_colors.dart';
import 'package:kinder_world/core/constants/app_constants.dart';
import 'package:kinder_world/core/models/child_profile.dart';
import 'package:kinder_world/core/providers/auth_provider.dart';
import 'package:kinder_world/core/providers/child_session_provider.dart';

class CreateChildProfileScreen extends ConsumerStatefulWidget {
  const CreateChildProfileScreen({super.key});

  @override
  ConsumerState<CreateChildProfileScreen> createState() => _CreateChildProfileScreenState();
}

class _CreateChildProfileScreenState extends ConsumerState<CreateChildProfileScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();
  
  // Step 1: Basic Info
  final _nameController = TextEditingController();
  int _selectedAge = 6;
  
  // Step 2: Avatar
  String _selectedAvatar = 'assets/images/avatars/boy1.png';
  
  // Step 3: Interests
  final List<String> _selectedInterests = [];
  
  // Step 4: Picture Password
  final List<String> _picturePassword = [];
  
  // Available avatars
  final List<String> _avatarOptions = [
    'assets/images/avatars/boy1.png',
    'assets/images/avatars/boy2.png',
    'assets/images/avatars/girl1.png',
    'assets/images/avatars/girl2.png',
  ];
  
  // Available interests
  final Map<String, String> _interestOptions = {
    'math': '🔢 Mathematics',
    'science': '🔬 Science',
    'reading': '📚 Reading',
    'art': '🎨 Art & Drawing',
    'music': '🎵 Music',
    'sports': '⚽ Sports',
    'animals': '🐾 Animals',
    'nature': '🌿 Nature',
  };
  
  // Available pictures for password
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

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onPictureSelected(String pictureId) {
    setState(() {
      if (_picturePassword.length < 3 && !_picturePassword.contains(pictureId)) {
        _picturePassword.add(pictureId);
      } else if (_picturePassword.contains(pictureId)) {
        _picturePassword.remove(pictureId);
      }
    });
  }

  void _onInterestSelected(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else if (_selectedInterests.length < 5) {
        _selectedInterests.add(interest);
      }
    });
  }

  Future<void> _createProfile() async {
    if (_formKey.currentState!.validate() && 
        _selectedInterests.isNotEmpty && 
        _picturePassword.length == 3) {
      
      // Create new child profile
      final newProfile = ChildProfile(
        id: 'child_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text,
        age: _selectedAge,
        avatar: _selectedAvatar,
        interests: _selectedInterests,
        level: 1,
        xp: 0,
        streak: 0,
        favorites: [],
        parentId: 'parent1', // In real app, get from auth
        picturePassword: _picturePassword,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        totalTimeSpent: 0,
        activitiesCompleted: 0,
        currentMood: 'happy',
      );
      
      // Authenticate and start session
      final authSuccess = await ref.read(authProvider.notifier).loginChild(
        childId: newProfile.id,
        picturePassword: _picturePassword,
      );
      
      if (authSuccess) {
        await ref.read(childSessionProvider.notifier).startChildSession(
          childId: newProfile.id,
          childProfile: newProfile,
        );
        
        if (mounted) {
          context.go('/child/home');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep--;
              });
            } else {
              context.go('/select-user-type');
            }
          },
        ),
        title: Text(
          'Create Child Profile',
          style: TextStyle(
            fontSize: AppConstants.fontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: List.generate(4, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: index <= _currentStep 
                            ? AppColors.primary 
                            : AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),
            
            // Step content
            Expanded(
              child: Form(
                key: _formKey,
                child: _buildCurrentStep(),
              ),
            ),
            
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _currentStep--;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: AppColors.primary),
                        ),
                        child: Text(
                          'Back',
                          style: TextStyle(
                            fontSize: AppConstants.fontSize,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _currentStep == 3 ? _createProfile : () {
                        setState(() {
                          _currentStep++;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        _currentStep == 3 ? 'Create Profile' : 'Next',
                        style: TextStyle(
                          fontSize: AppConstants.fontSize,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildBasicInfoStep();
      case 1:
        return _buildAvatarStep();
      case 2:
        return _buildInterestsStep();
      case 3:
        return _buildPicturePasswordStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tell us about your child',
            style: TextStyle(
              fontSize: AppConstants.largeFontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This helps us personalize their learning experience',
            style: TextStyle(
              fontSize: AppConstants.fontSize,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          
          // Name input
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Child\'s Name',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your child\'s name';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          
          // Age selector
          Text(
            'Age',
            style: TextStyle(
              fontSize: AppConstants.fontSize,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(7, (index) {
              final age = index + 5; // Ages 5-12
              return ChoiceChip(
                label: Text('$age years'),
                selected: _selectedAge == age,
                onSelected: (selected) {
                  setState(() {
                    _selectedAge = age;
                  });
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose an avatar',
            style: TextStyle(
              fontSize: AppConstants.largeFontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pick a fun character to represent your child',
            style: TextStyle(
              fontSize: AppConstants.fontSize,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _avatarOptions.length,
            itemBuilder: (context, index) {
              final avatar = _avatarOptions[index];
              final isSelected = _selectedAvatar == avatar;
              
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedAvatar = avatar;
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.lightGrey,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What are your child\'s interests?',
            style: TextStyle(
              fontSize: AppConstants.largeFontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select up to 5 interests (optional)',
            style: TextStyle(
              fontSize: AppConstants.fontSize,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.5,
            ),
            itemCount: _interestOptions.length,
            itemBuilder: (context, index) {
              final entry = _interestOptions.entries.elementAt(index);
              final isSelected = _selectedInterests.contains(entry.key);
              
              return InkWell(
                onTap: () => _onInterestSelected(entry.key),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.lightGrey,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPicturePasswordStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create a picture password',
            style: TextStyle(
              fontSize: AppConstants.largeFontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select 3 pictures your child will remember',
            style: TextStyle(
              fontSize: AppConstants.fontSize,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          
          // Selected pictures
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
                return Container(
                  width: 50,
                  height: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppColors.lightGrey,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.grey),
                  ),
                  child: _picturePassword.length > index
                      ? Center(
                          child: Text(
                            _pictureOptions.firstWhere(
                              (p) => p['id'] == _picturePassword[index]
                            )['icon'],
                            style: const TextStyle(fontSize: 24),
                          ),
                        )
                      : null,
                );
              }),
            ),
          ),
          const SizedBox(height: 32),
          
          // Picture options
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
              final isSelected = _picturePassword.contains(picture['id']);
              
              return InkWell(
                onTap: () => _onPictureSelected(picture['id']),
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
                        picture['icon'],
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        picture['name'],
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
        ],
      ),
    );
  }
}
