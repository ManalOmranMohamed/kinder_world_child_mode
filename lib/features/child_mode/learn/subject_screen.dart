import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kinder_world/core/theme/app_colors.dart';
import 'package:kinder_world/core/constants/app_constants.dart';

class SubjectScreen extends ConsumerWidget {
  final String subject;
  
  const SubjectScreen({
    super.key,
    required this.subject,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock lessons data
    final lessons = _getMockLessons(subject);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.go('/child/learn'),
        ),
        title: Text(
          _getSubjectDisplayName(subject),
          style: const TextStyle(
            fontSize: AppConstants.fontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subject header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _getSubjectColor(subject),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Icon(
                        _getSubjectIcon(subject),
                        size: 30,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getSubjectDisplayName(subject),
                            style: const TextStyle(
                              fontSize: AppConstants.largeFontSize,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                          Text(
                            '${lessons.length} lessons available',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Lessons list
              const Text(
                'Available Lessons',
                style: TextStyle(
                  fontSize: AppConstants.fontSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              
              Expanded(
                child: ListView.separated(
                  itemCount: lessons.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final lesson = lessons[index];
                    return _LessonCard(
                      lesson: lesson,
                      onTap: () {
                        context.go('/child/learn/lesson/${lesson['id']}');
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getMockLessons(String subject) {
    final allLessons = {
      'math': [
        {
          'id': 'math_01',
          'title': 'Counting Numbers 1-10',
          'description': 'Learn to count from 1 to 10',
          'duration': 15,
          'difficulty': 'Beginner',
          'xp': 50,
          'completed': true,
        },
        {
          'id': 'math_02',
          'title': 'Addition Basics',
          'description': 'Simple addition with small numbers',
          'duration': 20,
          'difficulty': 'Easy',
          'xp': 75,
          'completed': false,
        },
        {
          'id': 'math_03',
          'title': 'Shapes and Patterns',
          'description': 'Recognize different shapes and patterns',
          'duration': 18,
          'difficulty': 'Easy',
          'xp': 60,
          'completed': false,
        },
      ],
      'science': [
        {
          'id': 'sci_01',
          'title': 'Parts of a Plant',
          'description': 'Learn about roots, stem, leaves, and flowers',
          'duration': 12,
          'difficulty': 'Beginner',
          'xp': 50,
          'completed': true,
        },
        {
          'id': 'sci_02',
          'title': 'Animal Habitats',
          'description': 'Where do different animals live?',
          'duration': 25,
          'difficulty': 'Medium',
          'xp': 80,
          'completed': false,
        },
        {
          'id': 'sci_03',
          'title': 'Weather and Seasons',
          'description': 'Understanding weather patterns',
          'duration': 22,
          'difficulty': 'Easy',
          'xp': 65,
          'completed': false,
        },
      ],
      'reading': [
        {
          'id': 'read_01',
          'title': 'Alphabet Fun',
          'description': 'Learn all the letters A-Z',
          'duration': 30,
          'difficulty': 'Beginner',
          'xp': 50,
          'completed': true,
        },
        {
          'id': 'read_02',
          'title': 'Short Vowel Sounds',
          'description': 'Practice a, e, i, o, u sounds',
          'duration': 20,
          'difficulty': 'Easy',
          'xp': 70,
          'completed': false,
        },
        {
          'id': 'read_03',
          'title': 'Simple Words',
          'description': 'Form simple three-letter words',
          'duration': 25,
          'difficulty': 'Medium',
          'xp': 85,
          'completed': false,
        },
      ],
    };
    
    return allLessons[subject] ?? [];
  }

  String _getSubjectDisplayName(String subject) {
    switch (subject) {
      case 'math':
        return 'Mathematics';
      case 'science':
        return 'Science';
      case 'reading':
        return 'Reading';
      case 'history':
        return 'History';
      case 'geography':
        return 'Geography';
      default:
        return subject;
    }
  }

  Color _getSubjectColor(String subject) {
    switch (subject) {
      case 'math':
        return AppColors.educational;
      case 'science':
        return AppColors.skillful;
      case 'reading':
        return AppColors.behavioral;
      case 'history':
        return AppColors.entertaining;
      case 'geography':
        return AppColors.secondary;
      default:
        return AppColors.primary;
    }
  }

  IconData _getSubjectIcon(String subject) {
    switch (subject) {
      case 'math':
        return Icons.calculate;
      case 'science':
        return Icons.science;
      case 'reading':
        return Icons.book;
      case 'history':
        return Icons.history;
      case 'geography':
        return Icons.public;
      default:
        return Icons.school;
    }
  }
}

class _LessonCard extends StatelessWidget {
  final Map<String, dynamic> lesson;
  final VoidCallback onTap;
  
  const _LessonCard({
    required this.lesson,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Lesson icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                lesson['completed'] ? Icons.check_circle : Icons.play_circle,
                size: 30,
                color: lesson['completed'] ? AppColors.success : AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            
            // Lesson info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson['title'],
                    style: const TextStyle(
                      fontSize: AppConstants.fontSize,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lesson['description'],
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${lesson['duration']} min',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: AppColors.xpColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${lesson['xp']} XP',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.xpColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Difficulty badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                lesson['difficulty'],
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}