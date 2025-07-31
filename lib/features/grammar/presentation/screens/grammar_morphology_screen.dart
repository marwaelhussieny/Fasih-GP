// lib/features/grammar/presentation/screens/morphology_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// Removed direct color imports

class MorphologyScreen extends StatefulWidget {
  const MorphologyScreen({Key? key}) : super(key: key);

  @override
  State<MorphologyScreen> createState() => _MorphologyScreenState();
}

class _MorphologyScreenState extends State<MorphologyScreen> with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  List<Map<String, String>> _results = []; // To store morphology results
  bool _isLoading = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _performMorphology() async {
    if (_textController.text.trim().isEmpty) {
      _showSnackBar('الرجاء إدخال كلمة للتصريف.'); // Please enter a word for morphology.
      return;
    }

    setState(() {
      _isLoading = true;
      _results = []; // Clear previous results
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Dummy morphology results for "كتب" (kataba - to write)
    setState(() {
      _results = [
        {'pronoun': 'هو', 'conjugation': 'كتب'},
        {'pronoun': 'هي', 'conjugation': 'كتبت'},
        {'pronoun': 'هما (مذكر)', 'conjugation': 'كتبا'},
        {'pronoun': 'هما (مؤنث)', 'conjugation': 'كتبتا'},
        {'pronoun': 'هم', 'conjugation': 'كتبوا'},
        {'pronoun': 'هن', 'conjugation': 'كتبن'},
        {'pronoun': 'أنت', 'conjugation': 'كتبتَ'},
        {'pronoun': 'أنتِ', 'conjugation': 'كتبتِ'},
        {'pronoun': 'أنتما', 'conjugation': 'كتبتما'},
        {'pronoun': 'أنتم', 'conjugation': 'كتبتم'},
        {'pronoun': 'أنتن', 'conjugation': 'كتبتن'},
        {'pronoun': 'أنا', 'conjugation': 'كتبتُ'},
        {'pronoun': 'نحن', 'conjugation': 'كتبنا'},
      ];
      _isLoading = false;
      _animationController.forward(from: 0.0); // Start animation for new results
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: Theme.of(context).textTheme.bodyMedium)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final bool isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.background, // Use theme background color
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: theme.appBarTheme.iconTheme?.color,
            size: 22.r,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'الصرف', // Morphology
          style: textTheme.headlineSmall?.copyWith(
            color: theme.appBarTheme.titleTextStyle?.color,
            fontSize: 24.sp,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'أدخل كلمة للتصريف:', // Enter a word for morphology:
              style: textTheme.titleMedium?.copyWith(
                color: isDarkMode ? colorScheme.onBackground : colorScheme.primary, // Use onBackground/primary
                fontSize: 18.sp,
              ),
              textAlign: TextAlign.right,
            ),
            SizedBox(height: 15.h),
            TextField(
              controller: _textController,
              textAlign: TextAlign.right,
              style: textTheme.bodyMedium?.copyWith(
                color: isDarkMode ? colorScheme.onSurface : colorScheme.onBackground, // Use onSurface/onBackground
                fontSize: 16.sp,
              ),
              decoration: InputDecoration(
                hintText: 'اكتب هنا...', // Write here...
                hintStyle: textTheme.bodyMedium?.copyWith(
                  color: isDarkMode ? colorScheme.onSurface.withOpacity(0.5) : Colors.black54, // Replaced secondaryTextColor
                  fontSize: 16.sp,
                ),
                filled: true,
                fillColor: isDarkMode ? colorScheme.surface : Colors.white, // Use surface/white
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: isDarkMode ? colorScheme.outline : colorScheme.outline, // Use theme outline
                    width: 1.w,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: colorScheme.primary, // Use theme primary
                    width: 2.w,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: _isLoading ? null : _performMorphology,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary, // Use theme primary
                foregroundColor: colorScheme.onPrimary, // Use theme onPrimary
                padding: EdgeInsets.symmetric(vertical: 15.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 5,
                shadowColor: colorScheme.primary.withOpacity(0.3), // Use primary
              ),
              child: _isLoading
                  ? SizedBox(
                width: 24.w,
                height: 24.h,
                child: CircularProgressIndicator(
                  color: colorScheme.onPrimary, // Use onPrimary
                  strokeWidth: 2.w,
                ),
              )
                  : Text(
                'تصريف الكلمة', // Conjugate Word
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimary, // Use onPrimary
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 30.h),
            Expanded(
              child: _results.isEmpty && !_isLoading
                  ? Center(
                child: Text(
                  'نتائج التصريف ستظهر هنا.', // Morphology results will appear here.
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: isDarkMode ? colorScheme.onSurface.withOpacity(0.54) : Colors.black54, // Replaced secondaryTextColor
                    fontSize: 16.sp,
                  ),
                ),
              )
                  : ListView.builder(
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final result = _results[index];
                  return FadeTransition(
                    opacity: _animationController,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.5),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _animationController,
                        curve: Interval(
                          index / _results.length,
                          1.0,
                          curve: Curves.easeOut,
                        ),
                      )),
                      child: _buildMorphologyResultCard(
                        pronoun: result['pronoun']!,
                        conjugation: result['conjugation']!,
                        context: context,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMorphologyResultCard({
    required String pronoun,
    required String conjugation,
    required BuildContext context,
  }) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TextTheme textTheme = theme.textTheme;
    final bool isDarkMode = theme.brightness == Brightness.dark;

    Color color = colorScheme.secondary; // Use theme secondary color for these cards

    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: isDarkMode ? colorScheme.surface : Colors.white, // Use surface/white
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: color.withOpacity(0.4),
          width: 2.w,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? Colors.black : Colors.grey).withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end, // Align to right for Arabic
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end, // Align to right
            children: [
              Text(
                conjugation,
                style: textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.sp,
                ),
              ),
              SizedBox(width: 15.w),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  pronoun,
                  style: textTheme.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
