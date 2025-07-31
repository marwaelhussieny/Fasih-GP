// lib/features/profile/settings/accessibility_screen.dart
import 'package:flutter/material.dart';

class AccessibilityScreen extends StatefulWidget {
  const AccessibilityScreen({Key? key}) : super(key: key);

  @override
  State<AccessibilityScreen> createState() => _AccessibilityScreenState();
}

class _AccessibilityScreenState extends State<AccessibilityScreen> {
  // State variables for the toggle switches
  bool _listeningQuestions = true; // أسئلة السمع
  bool _readingQuestions = true;   // أسئلة القراءة
  bool _writingQuestions = true;   // أسئلة الكتابة
  bool _speakingQuestions = true;  // أسئلة التحدث
  bool _audioCues = false;        // المؤشرات الصوتية
  bool _hapticFeedback = false;    // الحث اللمسي

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
      body: ListView(
        children: [
          _buildAccessibilityToggle(
            title: 'أسئلة السمع',
            value: _listeningQuestions,
            onChanged: (value) {
              setState(() {
                _listeningQuestions = value;
                // TODO: Save preference (e.g., via a provider/use case)
              });
            },
          ),
          _buildAccessibilityToggle(
            title: 'أسئلة القراءة',
            value: _readingQuestions,
            onChanged: (value) {
              setState(() {
                _readingQuestions = value;
                // TODO: Save preference
              });
            },
          ),
          _buildAccessibilityToggle(
            title: 'أسئلة الكتابة',
            value: _writingQuestions,
            onChanged: (value) {
              setState(() {
                _writingQuestions = value;
                // TODO: Save preference
              });
            },
          ),
          _buildAccessibilityToggle(
            title: 'أسئلة التحدث',
            value: _speakingQuestions,
            onChanged: (value) {
              setState(() {
                _speakingQuestions = value;
                // TODO: Save preference
              });
            },
          ),
          _buildAccessibilityToggle(
            title: 'المؤشرات الصوتية', // Audio Cues
            value: _audioCues,
            onChanged: (value) {
              setState(() {
                _audioCues = value;
                // TODO: Save preference
              });
            },
          ),
          _buildAccessibilityToggle(
            title: 'الحث اللمسي', // Haptic Feedback
            value: _hapticFeedback,
            onChanged: (value) {
              setState(() {
                _hapticFeedback = value;
                // TODO: Save preference
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccessibilityToggle({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      title: Text(title),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}