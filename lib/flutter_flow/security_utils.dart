/// Security utility functions for input sanitization and brute force protection
class SecurityUtils {
  /// Sanitizes password input to prevent injection attacks
  /// Removes dangerous characters and normalizes input
  static String sanitizePassword(String password) {
    // Remove null bytes, control characters, and dangerous Unicode
    String sanitized = password
        .replaceAll(RegExp(r'[\x00-\x1F\x7F-\x9F]'), '') // Control chars
        .replaceAll(RegExp(r'[<>"\\]'), '') // Dangerous chars
        .replaceAll("'", '') // Single quote
        .trim();
    
    // Limit maximum length to prevent buffer overflow attacks
    const int maxLength = 128;
    if (sanitized.length > maxLength) {
      sanitized = sanitized.substring(0, maxLength);
    }
    
    return sanitized;
  }

  /// Validates password meets security requirements
  static String? validatePasswordSecurity(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    if (password.length > 128) {
      return 'Password cannot exceed 128 characters';
    }
    
    // Check for suspicious patterns
    if (RegExp(r'<script|javascript:|on\w+=', caseSensitive: false).hasMatch(password)) {
      return 'Password contains invalid characters';
    }
    
    return null;
  }

  /// Sanitizes email input
  static String sanitizeEmail(String email) {
    // Remove null bytes and control characters
    String sanitized = email
        .replaceAll(RegExp(r'[\x00-\x1F\x7F-\x9F]'), '')
        .trim()
        .toLowerCase();
    
    // Limit maximum length
    const int maxLength = 255;
    if (sanitized.length > maxLength) {
      sanitized = sanitized.substring(0, maxLength);
    }
    
    return sanitized;
  }
}

/// Brute force protection tracker
class BruteForceProtection {
  static final Map<String, List<DateTime>> _failedAttempts = {};
  static final Map<String, DateTime> _lockedUntil = {};
  
  // Configuration
  static const int maxFailedAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 5);
  static const Duration shortLockoutDuration = Duration(seconds: 30); // For first few attempts
  static const Duration windowDuration = Duration(minutes: 15); // Time window for tracking
  
  /// Records a failed login attempt
  static void recordFailedAttempt(String identifier) {
    final now = DateTime.now();
    _failedAttempts.putIfAbsent(identifier, () => []);
    
    // Clean old attempts outside the window
    _failedAttempts[identifier]!.removeWhere(
      (attempt) => now.difference(attempt) > windowDuration,
    );
    
    // Add new failed attempt
    _failedAttempts[identifier]!.add(now);
    
    final attempts = _failedAttempts[identifier]!.length;
    
    // Lock account if max attempts reached
    if (attempts >= maxFailedAttempts) {
      _lockedUntil[identifier] = now.add(lockoutDuration);
      // Clear attempts after lockout
      _failedAttempts[identifier]!.clear();
    } else if (attempts >= 3) {
      // Short lockout after 3 attempts
      _lockedUntil[identifier] = now.add(shortLockoutDuration);
    }
  }
  
  /// Records a successful login attempt and clears failures
  static void recordSuccess(String identifier) {
    _failedAttempts.remove(identifier);
    _lockedUntil.remove(identifier);
  }
  
  /// Checks if login is currently locked due to brute force protection
  static bool isLocked(String identifier) {
    final lockUntil = _lockedUntil[identifier];
    if (lockUntil == null) {
      return false;
    }
    
    // Remove expired lockouts
    if (DateTime.now().isAfter(lockUntil)) {
      _lockedUntil.remove(identifier);
      return false;
    }
    
    return true;
  }
  
  /// Gets the remaining lockout time
  static Duration? getRemainingLockoutTime(String identifier) {
    final lockUntil = _lockedUntil[identifier];
    if (lockUntil == null) {
      return null;
    }
    
    final remaining = lockUntil.difference(DateTime.now());
    if (remaining.isNegative) {
      _lockedUntil.remove(identifier);
      return null;
    }
    
    return remaining;
  }
  
  /// Gets the number of failed attempts in the current window
  static int getFailedAttemptCount(String identifier) {
    final now = DateTime.now();
    _failedAttempts.putIfAbsent(identifier, () => []);
    
    // Clean old attempts
    _failedAttempts[identifier]!.removeWhere(
      (attempt) => now.difference(attempt) > windowDuration,
    );
    
    return _failedAttempts[identifier]!.length;
  }
  
  /// Clears all protection data (for testing/admin purposes)
  static void clear() {
    _failedAttempts.clear();
    _lockedUntil.clear();
  }
}

