// lib/features/grammar/presentation/screens/morphology_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grad_project/features/home/presentation/screens/home_screen.dart' show primaryOrange, desertSand, nightBlue, starGold, lightOrange, darkPurple, warmAmber; // Import theme colors

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
      _showSnackBar('الرجاء إدخال كلمة للتصريف.');
      return;
    }

    setState(() {
      _isLoading = true;
      _results = [];
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _results = [
        {'pronoun': 'أنا', 'conjugation': 'اشتريت'},
        {'pronoun': 'أنتَ', 'conjugation': 'اشتريتَ'},
        {'pronoun': 'أنتِ', 'conjugation': 'اشتريتِ'},
        {'pronoun': 'هو', 'conjugation': 'اشترى'},
        {'pronoun': 'هي', 'conjugation': 'اشترت'},
        {'pronoun': 'نحن', 'conjugation': 'اشترينا'},
        {'pronoun': 'أنتم', 'conjugation': 'اشتريتم'},
        {'pronoun': 'أنتن', 'conjugation': 'اشتريتن'},
        {'pronoun': 'هم', 'conjugation': 'اشتروا'},
        {'pronoun': 'هن', 'conjugation': 'اشترين'},
      ];
      _isLoading = false;
    });

    _animationController.forward();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontFamily: 'Tajawal', fontSize: 14.sp),
        ),
        backgroundColor: lightOrange, // Using lightOrange for morphology specific snackbar
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? nightBlue : desertSand,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDarkMode ? Colors.white : lightOrange, // Using lightOrange for app bar icon
            size: 22.r,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'اصرفلي', // Morphology
          style: TextStyle(
            color: isDarkMode ? Colors.white : lightOrange, // Using lightOrange for app bar title
            fontWeight: FontWeight.bold,
            fontSize: 24.sp,
            fontFamily: 'Tajawal',
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(25.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Enhanced Input Field
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDarkMode
                      ? [darkPurple.withOpacity(0.8), nightBlue.withOpacity(0.6)]
                      : [Colors.white, desertSand.withOpacity(0.3)],
                ),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isDarkMode ? warmAmber.withOpacity(0.4) : lightOrange.withOpacity(0.4), // Using warmAmber/lightOrange for border
                  width: 2.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDarkMode ? Colors.black : Colors.grey).withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: TextField(
                controller: _textController,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontSize: 18.sp,
                  fontFamily: 'Tajawal',
                ),
                decoration: InputDecoration(
                  hintText: 'أدخل الكلمة المراد تصريفها هنا...', // Updated hint text
                  hintStyle: TextStyle(
                    color: isDarkMode ? Colors.white54 : Colors.grey.shade600,
                    fontSize: 16.sp,
                    fontFamily: 'Tajawal',
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(15.w),
                    child: Icon(
                      Icons.text_fields_rounded, // Can be changed to a more morphology-specific icon if available
                      color: isDarkMode ? warmAmber.withOpacity(0.7) : lightOrange.withOpacity(0.7), // Using warmAmber/lightOrange for icon
                      size: 24.r,
                    ),
                  ),
                ),
                maxLines: null,
                minLines: 3,
              ),
            ),
            SizedBox(height: 25.h),

            // Enhanced Action Button
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [lightOrange, lightOrange.withOpacity(0.8)], // Using lightOrange for button gradient
                ),
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: lightOrange.withOpacity(0.4), // Using lightOrange for button shadow
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _performMorphology,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 18.h),
                ),
                child: _isLoading
                    ? SizedBox(
                  height: 24.r,
                  width: 24.r,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_stories, color: Colors.white, size: 24.r), // Changed icon for morphology
                    SizedBox(width: 12.w),
                    Text(
                      'صرف الكلمة', // Updated button text
                      style: TextStyle(
                        fontFamily: 'Tajawal',
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 25.h),

            // Results Display
            Expanded(
              child: _isLoading
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: lightOrange, // Using lightOrange for loading indicator
                      strokeWidth: 4,
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'جاري التصريف...', // Updated loading text
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
                        fontSize: 16.sp,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ],
                ),
              )
                  : _results.isEmpty
                  ? _buildEmptyState(isDarkMode)
                  : _buildResultsList(isDarkMode),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(30.w),
            decoration: BoxDecoration(
              color: (isDarkMode ? warmAmber : lightOrange).withOpacity(0.1), // Using warmAmber/lightOrange for empty state icon background
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.format_list_numbered_rtl, // Changed icon for morphology empty state
              size: 60.r,
              color: isDarkMode ? warmAmber.withOpacity(0.7) : lightOrange.withOpacity(0.7), // Using warmAmber/lightOrange for empty state icon
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'نتائج التصريف ستظهر هنا', // Updated empty state text
            style: TextStyle(
              color: isDarkMode ? Colors.white54 : Colors.grey.shade600,
              fontSize: 18.sp,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(bool isDarkMode) {
    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300 + (index * 100)),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, animation, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - animation)),
              child: Opacity(
                opacity: animation,
                child: _buildResultCard(
                  context,
                  pronoun: _results[index]['pronoun']!,
                  conjugation: _results[index]['conjugation']!,
                  isDarkMode: isDarkMode,
                  index: index,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildResultCard(BuildContext context, {
    required String pronoun,
    required String conjugation,
    required bool isDarkMode,
    required int index,
  }) {
    final colors = [
      isDarkMode ? warmAmber : lightOrange, // Using warmAmber/lightOrange for card colors
      isDarkMode ? lightOrange : warmAmber.withOpacity(0.8),
      isDarkMode ? warmAmber.withOpacity(0.8) : lightOrange,
      isDarkMode ? lightOrange : warmAmber.withOpacity(0.8),
    ];

    final color = colors[index % colors.length];

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [darkPurple.withOpacity(0.8), nightBlue.withOpacity(0.6)]
              : [Colors.white, desertSand.withOpacity(0.3)],
        ),
        borderRadius: BorderRadius.circular(20.r),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  pronoun,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: Text(
                  conjugation,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    fontFamily: 'Tajawal',
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
