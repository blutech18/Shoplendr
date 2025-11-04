import 'package:flutter/material.dart';

/// Form validation utilities for ShopLendr3
class FormValidators {
  /// Validates product name
  static String? validateProductName(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Product name is required';
    }
    if (value.trim().length < 3) {
      return 'Product name must be at least 3 characters';
    }
    if (value.length > 100) {
      return 'Product name must be less than 100 characters';
    }
    return null;
  }

  /// Validates product description
  static String? validateDescription(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Description is required';
    }
    if (value.trim().length < 10) {
      return 'Description must be at least 10 characters';
    }
    if (value.length > 200) {
      return 'Description must be less than 200 characters';
    }
    return null;
  }

  /// Validates price
  static String? validatePrice(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Price is required';
    }
    final price = double.tryParse(value);
    if (price == null) {
      return 'Please enter a valid number';
    }
    if (price < 0) {
      return 'Price cannot be negative';
    }
    if (price > 1000000) {
      return 'Price cannot exceed ₱1,000,000';
    }
    if (price == 0) {
      return 'Price must be greater than 0';
    }
    return null;
  }

  /// Validates sell/rent type
  static String? validateSellRent(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please specify if item is for sale or rent';
    }
    final normalized = value.trim().toLowerCase();
    if (normalized != 'sell' && normalized != 'rent') {
      return 'Please enter either "Sell" or "Rent"';
    }
    return null;
  }

  /// Validates category selection
  static String? validateCategory(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a category';
    }
    return null;
  }

  /// Validates condition selection
  static String? validateCondition(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a condition';
    }
    return null;
  }

  /// Validates image upload
  static String? validateImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return 'Please upload at least one image';
    }
    return null;
  }

  /// Validates display name
  static String? validateDisplayName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Display name is required';
    }
    if (value.trim().length < 2) {
      return 'Display name must be at least 2 characters';
    }
    if (value.length > 50) {
      return 'Display name must be less than 50 characters';
    }
    return null;
  }

  /// Validates username
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (value.length > 30) {
      return 'Username must be less than 30 characters';
    }
    // Check for valid username characters (alphanumeric and underscore)
    final validUsername = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!validUsername.hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }

  /// Validates phone number
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Phone number is optional
    }
    // Remove common formatting characters
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    // Check if it's a valid Philippine phone number (10-11 digits)
    final validPhone = RegExp(r'^(\+63|0)?[0-9]{10}$');
    if (!validPhone.hasMatch(cleaned)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Validates email
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates address
  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Address is optional
    }
    if (value.length > 200) {
      return 'Address must be less than 200 characters';
    }
    return null;
  }

  /// Validates quantity
  static String? validateQuantity(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Quantity is required';
    }
    final quantity = int.tryParse(value.trim());
    if (quantity == null) {
      return 'Please enter a valid number';
    }
    if (quantity < 1) {
      return 'Quantity must be at least 1';
    }
    if (quantity > 9999) {
      return 'Quantity cannot exceed 9999';
    }
    return null;
  }
}
