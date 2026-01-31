// lib/features/profile/settings/accessibility_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grad_project/features/profile/presentation/providers/user_provider.dart';

class AccessibilityScreen extends StatefulWidget {
  const AccessibilityScreen({Key? key}) : super(key: key);

  @override
  State<AccessibilityScreen> createState() => _AccessibilityScreenState();
}

class _AccessibilityScreenState extends State<AccessibilityScreen> {
  @override
  void initState() {
    super.initState();
    // Load preferences when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.preferences == null) {
        userProvider.loadPreferences();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسهيلات الاستخدام'), // Accessibility
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Go back to SettingsScreen
          },
        ),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final preferences = userProvider.preferences;

          // Show loading indicator if preferences are loading
          if (userProvider.isLoading && preferences == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Show error if failed to load preferences
          if (userProvider.error != null && preferences == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'خطأ في تحميل الإعدادات',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userProvider.error!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => userProvider.loadPreferences(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          // Show default values if no preferences loaded yet
          final accessibility = preferences?.accessibility;

          return ListView(
            children: [
              _buildAccessibilityToggle(
                context: context,
                title: 'أسئلة السمع',
                value: accessibility?.hearingQuestions ?? true,
                onChanged: (value) => _updateAccessibilitySetting(
                  context,
                  'hearingQuestions',
                  value,
                ),
              ),
              _buildAccessibilityToggle(
                context: context,
                title: 'أسئلة القراءة',
                value: accessibility?.readingQuestions ?? true,
                onChanged: (value) => _updateAccessibilitySetting(
                  context,
                  'readingQuestions',
                  value,
                ),
              ),
              _buildAccessibilityToggle(
                context: context,
                title: 'أسئلة الكتابة',
                value: accessibility?.writingQuestions ?? true,
                onChanged: (value) => _updateAccessibilitySetting(
                  context,
                  'writingQuestions',
                  value,
                ),
              ),
              _buildAccessibilityToggle(
                context: context,
                title: 'أسئلة التحدث',
                value: accessibility?.speakingQuestions ?? true,
                onChanged: (value) => _updateAccessibilitySetting(
                  context,
                  'speakingQuestions',
                  value,
                ),
              ),
              _buildAccessibilityToggle(
                context: context,
                title: 'المؤشرات الصوتية', // Audio Cues
                value: accessibility?.soundEffects ?? false,
                onChanged: (value) => _updateAccessibilitySetting(
                  context,
                  'soundEffects',
                  value,
                ),
              ),
              _buildAccessibilityToggle(
                context: context,
                title: 'الحث اللمسي', // Haptic Feedback
                value: accessibility?.hapticFeedback ?? false,
                onChanged: (value) => _updateAccessibilitySetting(
                  context,
                  'hapticFeedback',
                  value,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAccessibilityToggle({
    required BuildContext context,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return ListTile(
          title: Text(title),
          trailing: Switch(
            value: value,
            onChanged: userProvider.isLoading ? null : onChanged,
          ),
        );
      },
    );
  }

  Future<void> _updateAccessibilitySetting(
      BuildContext context,
      String key,
      bool value,
      ) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      await userProvider.updateAccessibilityPreference(key, value);

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تحديث الإعدادات بنجاح'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تحديث الإعدادات: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}