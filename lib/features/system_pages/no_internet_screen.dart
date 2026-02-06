import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kinder_world/core/theme/app_colors.dart';
import 'package:kinder_world/core/constants/app_constants.dart';
import 'package:lottie/lottie.dart';

class NoInternetScreen extends ConsumerStatefulWidget {
  const NoInternetScreen({super.key});

  @override
  ConsumerState<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends ConsumerState<NoInternetScreen> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: child,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animation
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Lottie.asset(
                    'assets/animations/no_internet.json',
                    fit: BoxFit.contain,
                    repeat: true,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Title
                Text(
                  'No Internet Connection',
                  style: textTheme.titleLarge?.copyWith(
                    fontSize: AppConstants.largeFontSize * 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // Description
                Text(
                  'Don\'t worry! You can still use offline features. Some content may be limited until you\'re back online.',
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: AppConstants.fontSize,
                    color: colors.onSurfaceVariant,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Offline Features
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Offline:',
                        style: textTheme.titleSmall?.copyWith(
                          fontSize: AppConstants.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildOfflineFeature(Icons.school, 'Downloaded lessons'),
                      const SizedBox(height: 12),
                      _buildOfflineFeature(Icons.games, 'Saved games'),
                      const SizedBox(height: 12),
                      _buildOfflineFeature(Icons.book, 'Offline stories'),
                      const SizedBox(height: 12),
                      _buildOfflineFeature(Icons.person, 'Progress tracking'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Retry Button
                ElevatedButton.icon(
                  onPressed: () {
                    final messenger = ScaffoldMessenger.of(context);
                    // Simulate checking connection
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Checking connection...'),
                        backgroundColor: AppColors.info,
                      ),
                    );
                    
                    Future.delayed(const Duration(seconds: 2), () {
                      if (!mounted) {
                        return;
                      }
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Still no connection. Please check your internet.'),
                          backgroundColor: AppColors.warning,
                        ),
                      );
                    });
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: colors.onPrimary,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Continue Offline Button
                OutlinedButton(
                  onPressed: () {
                    // Navigate back to the app in offline mode
                    context.go('/child/home');
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Continue Offline'),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOfflineFeature(IconData icon, String text) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: textTheme.bodyMedium?.copyWith(
            fontSize: AppConstants.fontSize,
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
