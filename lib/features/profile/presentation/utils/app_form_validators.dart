// lib/features/profile/presentation/utils/app_form_validators.dart

class AppFormValidators {
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'الاسم لا يمكن أن يكون فارغًا.'; // Name cannot be empty.
    }
    if (value.length < 2) {
      return 'الاسم قصير جداً.'; // Name is too short.
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'البريد الإلكتروني لا يمكن أن يكون فارغًا.'; // Email cannot be empty.
    }
    // Simple email regex for basic validation
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegExp.hasMatch(value)) {
      return 'البريد الإلكتروني غير صالح.'; // Invalid email.
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone number is optional
    }
    // Basic phone number validation (e.g., Arabic numbers, common lengths)
    final phoneRegExp = RegExp(r'^(01)[0-2|5]{1}[0-9]{8}$'); // Example for Egyptian numbers
    if (!phoneRegExp.hasMatch(value)) {
      return 'رقم الهاتف غير صالح.'; // Invalid phone number.
    }
    return null;
  }

  static String? validateJob(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Job is optional
    }
    if (value.length < 2) {
      return 'الوظيفة قصيرة جداً.'; // Job is too short.
    }
    return null;
  }

  static String? validateDateOfBirth(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Date of birth is optional
    }
    // You might add more complex date validation here if needed
    return null;
  }
}