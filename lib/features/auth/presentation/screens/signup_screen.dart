// lib/features/auth/presentation/screens/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

// Import your authentication provider
import 'package:grad_project/features/auth/presentation/providers/auth_provider.dart';

// Import your app routes for navigation
import 'package:grad_project/core/navigation/app_routes.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Controllers for text input fields
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // State variables for password visibility toggles
  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;

  // GlobalKey for form validation
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Dispose controllers to free up resources when the widget is removed
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Validator for full name
  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'الاسم الكامل مطلوب';
    }
    return null;
  }

  // Validator for email
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'أدخل بريد إلكتروني صالح';
    }
    return null;
  }

  // Validator for password
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    if (value.length < 6) {
      return 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';
    }
    return null;
  }

  // Validator for confirm password
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'تأكيد كلمة المرور مطلوب';
    }
    if (value != _passwordController.text) {
      return 'كلمات المرور غير متطابقة';
    }
    return null;
  }

  // Implement the sign-up logic using AuthProvider
  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final email = _emailController.text.trim();

      // Call the signUp method from the AuthProvider
      await authProvider.signUp(
        fullName: _fullNameController.text.trim(),
        email: email,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      );

      // Check the result from the AuthProvider
      if (mounted) {
        if (authProvider.error == null) {
          // Success - show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'تم إنشاء الحساب بنجاح! يرجى التحقق من بريدك الإلكتروني',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              backgroundColor: Theme.of(context).primaryColor,
              duration: const Duration(seconds: 2),
            ),
          );

          // Navigate to OTP verification screen after a short delay
          await Future.delayed(const Duration(milliseconds: 500));

          if (mounted) {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.otp,
              arguments: {'email': email},
            );
          }
        } else {
          // Error occurred
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                authProvider.error!, // Display error message from provider
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  color: Theme.of(context).colorScheme.onError,
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get theme-dependent colors and text styles
    final ThemeData theme = Theme.of(context);
    final Color backgroundColor = theme.scaffoldBackgroundColor;
    final Color textColor = theme.textTheme.bodyLarge!.color!;
    final Color mutedTextColor = theme.hintColor;
    final Color primaryColor = theme.primaryColor;

    // Listen to AuthProvider for loading state
    final authProvider = Provider.of<AuthProvider>(context);
    final bool isLoading = authProvider.isLoading;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 20.h),

                // Back button
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: textColor, size: 24.r),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                    ),
                    const Spacer(),
                  ],
                ),

                SizedBox(height: 60.h),

                // Title
                Text(
                  'إنشاء حساب',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: textColor,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'يرجى إدخال البيانات لتسجيل حساب جديد',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: mutedTextColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 60.h),

                // Full Name Input Field
                _buildTextField(
                  context: context,
                  controller: _fullNameController,
                  hint: 'الاسم الكامل',
                  icon: Icons.person,
                  validator: _validateFullName,
                ),
                SizedBox(height: 20.h),

                // Email Input Field
                _buildTextField(
                  context: context,
                  controller: _emailController,
                  hint: 'البريد الإلكتروني',
                  icon: Icons.mail,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                SizedBox(height: 20.h),

                // Password Input Field
                _buildTextField(
                  context: context,
                  controller: _passwordController,
                  hint: 'كلمة المرور',
                  icon: Icons.key,
                  obscure: !_isPasswordVisible,
                  isPassword: true,
                  toggleVisibility: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  validator: _validatePassword,
                ),
                SizedBox(height: 20.h),

                // Confirm Password Input Field
                _buildTextField(
                  context: context,
                  controller: _confirmPasswordController,
                  hint: 'تأكيد كلمة المرور',
                  icon: Icons.lock,
                  obscure: !_isConfirmVisible,
                  isPassword: true,
                  toggleVisibility: () {
                    setState(() {
                      _isConfirmVisible = !_isConfirmVisible;
                    });
                  },
                  validator: _validateConfirmPassword,
                ),
                SizedBox(height: 60.h),

                // Create Account Button
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _signUp,
                    style: theme.elevatedButtonTheme.style?.copyWith(
                      backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                          if (states.contains(MaterialState.disabled)) {
                            return primaryColor.withOpacity(0.6);
                          }
                          return theme.elevatedButtonTheme.style?.backgroundColor?.resolve(states);
                        },
                      ),
                      foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                          return theme.elevatedButtonTheme.style?.foregroundColor?.resolve(states);
                        },
                      ),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26.r),
                      )),
                      minimumSize: MaterialStateProperty.all(Size(double.infinity, 52.h)),
                    ),
                    child: isLoading
                        ? SizedBox(
                      height: 20.r,
                      width: 20.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.onPrimary),
                      ),
                    )
                        : Text(
                      'إنشاء حساب',
                      style: theme.elevatedButtonTheme.style?.textStyle?.resolve({})?.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // Already have account? Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'لديك حساب بالفعل؟ ',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 14.sp,
                        color: textColor,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.login);
                      },
                      child: Text(
                        'تسجيل الدخول',
                        style: theme.textButtonTheme.style?.textStyle?.resolve({})?.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Guest login
                InkWell(
                  onTap: () {
                    print('Continue as guest');
                    Navigator.pushReplacementNamed(context, AppRoutes.home);
                  },
                  child: Text(
                    'المتابعة كضيف',
                    style: theme.textButtonTheme.style?.textStyle?.resolve({})?.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: mutedTextColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget to build text input fields (modified to be theme-aware and responsive)
  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    bool isPassword = false,
    VoidCallback? toggleVisibility,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    final ThemeData theme = Theme.of(context);
    final Color primaryColor = theme.primaryColor;
    final Color textColor = theme.textTheme.bodyLarge!.color!;
    final Color mutedTextColor = theme.hintColor;
    final Color errorColor = theme.colorScheme.error;

    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 50.h,
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: primaryColor,
              size: 20.r,
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: controller,
              obscureText: obscure,
              textAlign: TextAlign.right,
              keyboardType: keyboardType,
              style: TextStyle(
                fontFamily: 'Tajawal',
                fontSize: 14.sp,
                color: textColor,
              ),
              decoration: InputDecoration(
                suffixIcon: isPassword
                    ? IconButton(
                  icon: Icon(
                    obscure ? Icons.visibility_off : Icons.visibility,
                    color: primaryColor,
                    size: 20.r,
                  ),
                  onPressed: toggleVisibility,
                )
                    : null,
                hintText: hint,
                hintStyle: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14.sp,
                  color: mutedTextColor,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 15.h),
                errorStyle: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 10.sp,
                  color: errorColor,
                ),
              ),
              validator: validator,
            ),
          ),
        ],
      ),
    );
  }
}