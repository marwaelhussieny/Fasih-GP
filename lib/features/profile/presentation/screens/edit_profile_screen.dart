// lib/features/profile/presentation/screens/edit_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemUiOverlayStyle
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io'; // For File

// Corrected import path for UserProvider
import 'package:grad_project/features/profile/presentation/providers/user_provider.dart';
import 'package:grad_project/features/profile/domain/entities/user_entity.dart';

// FIX: Corrected import paths for utility files (assuming 'app_' prefix and 'utils' folder)
import 'package:grad_project/features/profile/presentation/utils/app_form_validators.dart';
import 'package:grad_project/features/profile/presentation/utils/app_dialog_utils.dart';
import 'package:grad_project/features/profile/presentation/utils/app_snackbar_utils.dart';

// FIX: Corrected import paths for individual widgets (assuming 'profile_widgets' subfolder)
import 'package:grad_project/features/profile/presentation/widgets/edit_profile_widgets/profile_image_section.dart';
import 'package:grad_project/features/profile/presentation/widgets/edit_profile_widgets/edit_profile_widgets.dart';
import 'package:grad_project/features/profile/presentation/widgets/edit_profile_widgets/edit_profile_form.dart'; // Contains buildLoadingState, buildErrorState, buildNoDataState, buildSaveButton

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _dateOfBirthController;
  late TextEditingController _jobController;
  DateTime? _selectedDateOfBirth;
  File? _imageFile;
  bool _isFormChanged = false;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure context is fully built before initializing controllers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeControllers();
    });
  }

  void _initializeControllers() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final UserEntity? currentUser = userProvider.user;

    // Initialize controllers with current user data or empty string
    _nameController = TextEditingController(text: currentUser?.name ?? '');
    _phoneController = TextEditingController(text: currentUser?.phoneNumber ?? '');
    _emailController = TextEditingController(text: currentUser?.email ?? '');
    _jobController = TextEditingController(text: currentUser?.job ?? '');
    _selectedDateOfBirth = currentUser?.dateOfBirth;
    _dateOfBirthController = TextEditingController(
      text: _selectedDateOfBirth != null
          ? DateFormat('dd/MM/yyyy', 'ar').format(_selectedDateOfBirth!)
          : '',
    );

    // Add listeners to track form changes
    _nameController.addListener(_onFormChanged);
    _phoneController.addListener(_onFormChanged);
    _emailController.addListener(_onFormChanged);
    _jobController.addListener(_onFormChanged);
    // Note: _dateOfBirthController doesn't need a listener as changes are from date picker
  }

  // Method to mark form as changed
  void _onFormChanged() {
    if (!_isFormChanged) {
      setState(() {
        _isFormChanged = true;
      });
    }
  }

  @override
  void dispose() {
    // Dispose controllers and remove listeners
    _nameController.removeListener(_onFormChanged);
    _phoneController.removeListener(_onFormChanged);
    _emailController.removeListener(_onFormChanged);
    _jobController.removeListener(_onFormChanged);

    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dateOfBirthController.dispose();
    _jobController.dispose();
    super.dispose();
  }

  // Method to show date picker and update selected date
  Future<void> _selectDateOfBirth(BuildContext context) async {
    final ThemeData currentTheme = Theme.of(context);
    // Theming for date picker is handled by currentTheme.copyWith
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now().subtract(const Duration(days: 6570)), // Default to 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('ar', 'SA'), // Ensure Arabic locale for date picker
      builder: (context, child) {
        // Apply the current app's theme to the date picker
        return Theme(
          data: currentTheme.copyWith(
            colorScheme: currentTheme.colorScheme.copyWith(
              primary: currentTheme.primaryColor, // Use app's primary color
              onPrimary: currentTheme.colorScheme.onPrimary, // Use app's onPrimary color
              onSurface: currentTheme.textTheme.bodyLarge?.color, // Use app's text color for date picker surface
              surface: currentTheme.cardColor, // Use app's card color for date picker background
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: currentTheme.primaryColor, // Use app's primary color for text buttons
              ),
            ),
            // Ensure correct text style for date picker header/body
            textTheme: currentTheme.textTheme.copyWith(
              titleLarge: currentTheme.textTheme.titleLarge?.copyWith(fontFamily: 'Tajawal'),
              bodyLarge: currentTheme.textTheme.bodyLarge?.copyWith(fontFamily: 'Tajawal'),
              labelLarge: currentTheme.textTheme.labelLarge?.copyWith(fontFamily: 'Tajawal'),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
        _dateOfBirthController.text = DateFormat('dd/MM/yyyy', 'ar').format(picked); // Format with Arabic locale
        _isFormChanged = true; // Mark form as changed
      });
    }
  }

  // Callback for when a new image is picked
  void _onImagePicked(File imageFile) {
    setState(() {
      _imageFile = imageFile;
      _isFormChanged = true; // Mark form as changed
    });
  }

  // Method to save profile changes
  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      try {
        AppDialogUtils.showLoadingDialog(context); // Use AppDialogUtils

        await userProvider.updateUserProfileData(
          name: _nameController.text,
          email: _emailController.text,
          phoneNumber: _phoneController.text, // Correctly pass phoneNumber
          dateOfBirth: _selectedDateOfBirth, // Correctly pass dateOfBirth
          job: _jobController.text, // Correctly pass job
        );

        if (_imageFile != null) {
          await userProvider.uploadProfileImageFile(imageFile: _imageFile!);
        }

        if (mounted) Navigator.pop(context); // Close loading dialog

        if (userProvider.error == null) {
          if (mounted) {
            AppSnackbarUtils.showSuccessSnackBar(context, 'تم حفظ التغييرات بنجاح'); // Use AppSnackbarUtils
            Navigator.pop(context, true); // Pop screen, indicating success
          }
        } else {
          if (mounted) {
            AppSnackbarUtils.showErrorSnackBar(context, 'خطأ: ${userProvider.error}'); // Use AppSnackbarUtils
          }
        }
      } catch (e) {
        if (mounted) Navigator.pop(context); // Close loading dialog
        if (mounted) {
          AppSnackbarUtils.showErrorSnackBar(context, 'حدث خطأ غير متوقع: ${e.toString()}'); // Use AppSnackbarUtils
        }
      }
    }
  }

  // Handle back button press to prompt about unsaved changes
  Future<bool> _onWillPop() async {
    if (_isFormChanged || _imageFile != null) {
      return await AppDialogUtils.showDiscardChangesDialog(context); // Use AppDialogUtils
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: _buildAppBar(theme),
        body: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            final UserEntity? currentUser = userProvider.user;

            // Show loading state if user data is being fetched for the first time
            if (userProvider.isLoading && currentUser == null) {
              return EditProfileWidgets.buildLoadingState(theme);
            }

            // Show error state if there's an error and no user data
            if (userProvider.error != null && currentUser == null) {
              return EditProfileWidgets.buildErrorState(theme, userProvider);
            }

            // Show no data state if no user is logged in or profile not found
            if (currentUser == null) {
              return EditProfileWidgets.buildNoDataState(theme);
            }

            // Build the main content of the screen
            return _buildMainContent(theme, currentUser, userProvider);
          },
        ),
      ),
    );
  }

  // Helper method to build the AppBar
  PreferredSizeWidget _buildAppBar(ThemeData theme) {
    return AppBar(
      backgroundColor: Colors.transparent, // AppBar background is transparent to show scaffold background
      elevation: 0, // No shadow
      // Set system overlay style for status bar icons (light/dark)
      systemOverlayStyle: theme.brightness == Brightness.dark
          ? SystemUiOverlayStyle.light // Dark mode: light icons
          : SystemUiOverlayStyle.dark, // Light mode: dark icons
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: theme.appBarTheme.iconTheme?.color, // Use themed icon color
          size: 20.r, // Responsive size
        ),
        onPressed: () async {
          if (await _onWillPop()) { // Check for unsaved changes
            Navigator.pop(context);
          }
        },
      ),
      centerTitle: true,
      title: Text(
        'تعديل الحساب الشخصي', // Edit Personal Account
        style: theme.appBarTheme.titleTextStyle?.copyWith( // Use themed title text style
          fontSize: 18.sp, // Responsive font size
          fontWeight: FontWeight.w600,
        ) ?? const TextStyle(), // Fallback
      ),
      actions: [
        // Show "Save" button only if form has changed or image is picked
        if (_isFormChanged || _imageFile != null)
          TextButton(
            onPressed: Provider.of<UserProvider>(context).isLoading ? null : _saveProfile, // Disable if loading
            child: Text(
              'حفظ', // Save
              style: theme.textButtonTheme.style?.textStyle?.resolve({})?.copyWith( // Use themed text button style
                fontSize: 14.sp, // Responsive font size
                fontWeight: FontWeight.w600,
                color: theme.primaryColor, // Use themed primary color
              ),
            ),
          ),
      ],
    );
  }

  // Helper method to build the main scrollable content
  Widget _buildMainContent(ThemeData theme, UserEntity currentUser, UserProvider userProvider) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Image Section
            ProfileImageSection(
              currentUser: currentUser,
              imageFile: _imageFile,
              onImagePicked: _onImagePicked,
            ),
            SizedBox(height: 32.h),

            // Edit Profile Form (contains text fields)
            EditProfileForm(
              nameController: _nameController,
              phoneController: _phoneController,
              emailController: _emailController,
              dateOfBirthController: _dateOfBirthController,
              jobController: _jobController,
              onDateOfBirthTap: () => _selectDateOfBirth(context),
            ),
            SizedBox(height: 40.h),

            // Save Button
            EditProfileWidgets.buildSaveButton(
              context: context,
              isLoading: userProvider.isLoading,
              onPressed: _saveProfile,
            ),
            SizedBox(height: 20.h), // Add some bottom padding
          ],
        ),
      ),
    );
  }
}
