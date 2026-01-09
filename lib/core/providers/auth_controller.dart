import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kinder_world/core/models/user.dart';
import 'package:kinder_world/core/repositories/auth_repository.dart';
import 'package:kinder_world/app.dart';
import 'package:logger/logger.dart';

// ==================== AUTH STATE ====================

/// Authentication state
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }

  bool get isParent => user?.role == UserRoles.parent;
  bool get isChild => user?.role == UserRoles.child;
}

// ==================== AUTH CONTROLLER ====================

/// Authentication controller - SINGLE SOURCE OF TRUTH
class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final Logger _logger;

  AuthController({
    required AuthRepository authRepository,
    required Logger logger,
  })  : _authRepository = authRepository,
        _logger = logger,
        super(const AuthState()) {
    _initialize();
  }

  /// Initialize authentication state
  Future<void> _initialize() async {
    _logger.d('Initializing auth controller');
    
    final isAuthenticated = await _authRepository.isAuthenticated();
    final user = await _authRepository.getCurrentUser();
    
    state = state.copyWith(
      isAuthenticated: isAuthenticated,
      user: user,
    );
    
    _logger.d('Auth initialized: authenticated=$isAuthenticated, user=${user?.id}');
  }

  // ==================== PARENT AUTHENTICATION ====================

  /// Login parent with email and password
  Future<bool> loginParent({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = await _authRepository.loginParent(
        email: email,
        password: password,
      );
      
      if (user != null) {
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );
        
        _logger.d('Parent login successful: ${user.id}');
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Invalid email or password',
        );
        return false;
      }
    } catch (e) {
      _logger.e('Parent login error: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Login failed. Please try again.',
      );
      return false;
    }
  }

  /// Register new parent account
  Future<bool> registerParent({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = await _authRepository.registerParent(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );
      
      if (user != null) {
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );
        
        _logger.d('Parent registration successful: ${user.id}');
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Registration failed. Please check your information.',
        );
        return false;
      }
    } catch (e) {
      _logger.e('Parent registration error: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Registration failed. Please try again.',
      );
      return false;
    }
  }

  // ==================== CHILD AUTHENTICATION ====================

  /// Login child with picture password
  Future<bool> loginChild({
    required String childId,
    required List<String> picturePassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = await _authRepository.loginChild(
        childId: childId,
        picturePassword: picturePassword,
      );
      
      if (user != null) {
        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );
        
        _logger.d('Child login successful: ${user.id}');
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Invalid picture password',
        );
        return false;
      }
    } catch (e) {
      _logger.e('Child login error: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Login failed. Please try again.',
      );
      return false;
    }
  }

  // ==================== LOGOUT ====================

  /// Logout current user
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    
    try {
      await _authRepository.logout();
      
      state = const AuthState(
        user: null,
        isAuthenticated: false,
        isLoading: false,
        error: null,
      );
      
      _logger.d('User logged out successfully');
    } catch (e) {
      _logger.e('Error during logout: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Logout failed',
      );
    }
  }

  // ==================== PARENT PIN ====================

  /// Set parent PIN
  Future<bool> setParentPin(String pin) async {
    try {
      return await _authRepository.setParentPin(pin);
    } catch (e) {
      _logger.e('Error setting parent PIN: $e');
      return false;
    }
  }

  /// Verify parent PIN
  Future<bool> verifyParentPin(String enteredPin) async {
    try {
      return await _authRepository.verifyParentPin(enteredPin);
    } catch (e) {
      _logger.e('Error verifying PIN: $e');
      return false;
    }
  }

  /// Check if PIN is required
  Future<bool> isPinRequired() async {
    try {
      return await _authRepository.isPinRequired();
    } catch (e) {
      _logger.e('Error checking PIN requirement: $e');
      return false;
    }
  }

  // ==================== UTILITIES ====================

  /// Refresh user data
  Future<void> refreshUser() async {
    try {
      final user = await _authRepository.getCurrentUser();
      state = state.copyWith(user: user);
    } catch (e) {
      _logger.e('Error refreshing user: $e');
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Validate token
  Future<bool> validateToken() async {
    try {
      return await _authRepository.validateToken();
    } catch (e) {
      _logger.e('Error validating token: $e');
      return false;
    }
  }
}

// ==================== PROVIDERS ====================

/// Main auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  final logger = ref.watch(loggerProvider);
  
  return AuthRepository(
    secureStorage: secureStorage,
    logger: logger,
  );
});

/// Main auth controller provider - SINGLE SOURCE OF TRUTH
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final logger = ref.watch(loggerProvider);
  
  return AuthController(
    authRepository: authRepository,
    logger: logger,
  );
});

// ==================== HELPER PROVIDERS ====================

/// Check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authControllerProvider).isAuthenticated;
});

/// Get current user
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authControllerProvider).user;
});

/// Check if current user is parent
final isParentProvider = Provider<bool>((ref) {
  return ref.watch(authControllerProvider).isParent;
});

/// Check if current user is child
final isChildProvider = Provider<bool>((ref) {
  return ref.watch(authControllerProvider).isChild;
});

/// Get user role
final userRoleProvider = Provider<String?>((ref) {
  return ref.watch(authControllerProvider).user?.role;
});

/// Get auth loading state
final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authControllerProvider).isLoading;
});

/// Get auth error
final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authControllerProvider).error;
});