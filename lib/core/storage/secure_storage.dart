import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage service for sensitive data
class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  // Storage keys
  static const String _keyAuthToken = 'auth_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserRole = 'user_role';
  static const String _keyParentPin = 'parent_pin';
  static const String _keyChildSession = 'child_session';

  // ==================== AUTH TOKEN ====================

  Future<String?> getAuthToken() async {
    try {
      return await _storage.read(key: _keyAuthToken);
    } catch (e) {
      return null;
    }
  }

  Future<bool> saveAuthToken(String token) async {
    try {
      await _storage.write(key: _keyAuthToken, value: token);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteAuthToken() async {
    try {
      await _storage.delete(key: _keyAuthToken);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== REFRESH TOKEN ====================

  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _keyRefreshToken);
    } catch (e) {
      return null;
    }
  }

  Future<bool> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: _keyRefreshToken, value: token);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteRefreshToken() async {
    try {
      await _storage.delete(key: _keyRefreshToken);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== USER ID ====================

  Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _keyUserId);
    } catch (e) {
      return null;
    }
  }

  Future<bool> saveUserId(String userId) async {
    try {
      await _storage.write(key: _keyUserId, value: userId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteUserId() async {
    try {
      await _storage.delete(key: _keyUserId);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== USER ROLE ====================

  Future<String?> getUserRole() async {
    try {
      return await _storage.read(key: _keyUserRole);
    } catch (e) {
      return null;
    }
  }

  Future<bool> saveUserRole(String role) async {
    try {
      await _storage.write(key: _keyUserRole, value: role);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteUserRole() async {
    try {
      await _storage.delete(key: _keyUserRole);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== PARENT PIN ====================

  Future<String?> getParentPin() async {
    try {
      return await _storage.read(key: _keyParentPin);
    } catch (e) {
      return null;
    }
  }

  Future<bool> saveParentPin(String pin) async {
    try {
      await _storage.write(key: _keyParentPin, value: pin);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteParentPin() async {
    try {
      await _storage.delete(key: _keyParentPin);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> hasParentPin() async {
    try {
      final pin = await getParentPin();
      return pin != null && pin.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // ==================== CHILD SESSION ====================

  Future<String?> getChildSession() async {
    try {
      return await _storage.read(key: _keyChildSession);
    } catch (e) {
      return null;
    }
  }

  Future<bool> saveChildSession(String childId) async {
    try {
      await _storage.write(key: _keyChildSession, value: childId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> clearChildSession() async {
    try {
      await _storage.delete(key: _keyChildSession);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== CLEAR ALL ====================

  Future<bool> clearAll() async {
    try {
      await _storage.deleteAll();
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== HELPERS ====================

  Future<bool> isAuthenticated() async {
    try {
      final token = await getAuthToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, String>> getAllSecureData() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      return {};
    }
  }

  /// Backwards-compatible alias for getting the parent id (previous API used getParentId)
  Future<String?> getParentId() async => getUserId();
}