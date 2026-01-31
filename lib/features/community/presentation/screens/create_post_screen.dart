// lib/features/community/presentation/screens/create_post_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:grad_project/core/theme/app_theme.dart';
import 'package:grad_project/features/community/presentation/providers/community_provider.dart';
import 'package:grad_project/features/community/data/models/community_models.dart';

class CreatePostScreen extends StatefulWidget {
  final bool isDarkMode;
  final List<CommunityCategory> categories;

  const CreatePostScreen({
    Key? key,
    required this.isDarkMode,
    required this.categories,
  }) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen>
    with TickerProviderStateMixin {
  final TextEditingController _contentController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String? selectedCategoryId;
  bool isPosting = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();

    // Set default category if available
    if (widget.categories.isNotEmpty) {
      selectedCategoryId = widget.categories.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkMode
          ? AppTheme.darkBackgroundColor
          : AppTheme.lightBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: widget.isDarkMode
                ? AppTheme.darkPrimaryTextColor
                : AppTheme.primaryTextColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'منشور جديد',
          style: TextStyle(
            color: widget.isDarkMode
                ? AppTheme.darkPrimaryTextColor
                : AppTheme.primaryTextColor,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'Tajawal',
          ),
        ),
        centerTitle: true,
        actions: [
          Consumer<CommunityProvider>(
            builder: (context, communityProvider, child) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: _canPost()
                      ? AppTheme.primaryBrandColor
                      : AppTheme.primaryBrandColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: TextButton(
                  onPressed: _canPost() && !isPosting
                      ? () => _publishPost(communityProvider)
                      : null,
                  child: isPosting
                      ? SizedBox(
                    width: 16.w,
                    height: 16.h,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Text(
                    'نشر',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Category Selection
                _buildCategorySelection(),
                SizedBox(height: 20.h),

                // Post Content
                _buildPostContent(),
                SizedBox(height: 20.h),

                // Post Guidelines
                _buildPostGuidelines(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: widget.isDarkMode
            ? AppTheme.darkCardColor
            : AppTheme.cardBackgroundColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppTheme.primaryBrandColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'اختر المجتمع',
                style: TextStyle(
                  color: widget.isDarkMode
                      ? AppTheme.darkPrimaryTextColor
                      : AppTheme.primaryTextColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Tajawal',
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBrandColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.category_outlined,
                  color: AppTheme.primaryBrandColor,
                  size: 18.r,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          DropdownButtonFormField<String>(
            value: selectedCategoryId,
            isExpanded: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: AppTheme.primaryBrandColor.withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: AppTheme.primaryBrandColor.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: AppTheme.primaryBrandColor,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: widget.isDarkMode
                  ? AppTheme.darkBackgroundColor
                  : Colors.white,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            ),
            style: TextStyle(
              color: widget.isDarkMode
                  ? AppTheme.darkPrimaryTextColor
                  : AppTheme.primaryTextColor,
              fontFamily: 'Tajawal',
            ),
            items: widget.categories.map((CommunityCategory category) {
              return DropdownMenuItem<String>(
                value: category.id,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      category.name,
                      style: TextStyle(fontFamily: 'Tajawal'),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      width: 8.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBrandColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  selectedCategoryId = newValue;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPostContent() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: widget.isDarkMode
            ? AppTheme.darkCardColor
            : AppTheme.cardBackgroundColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppTheme.primaryBrandColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'محتوى المنشور',
                style: TextStyle(
                  color: widget.isDarkMode
                      ? AppTheme.darkPrimaryTextColor
                      : AppTheme.primaryTextColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Tajawal',
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBrandColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.edit_outlined,
                  color: AppTheme.primaryBrandColor,
                  size: 18.r,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: _contentController,
            maxLines: 8,
            minLines: 4,
            textAlign: TextAlign.right,
            onChanged: (value) => setState(() {}),
            style: TextStyle(
              color: widget.isDarkMode
                  ? AppTheme.darkPrimaryTextColor
                  : AppTheme.primaryTextColor,
              fontSize: 16.sp,
              fontFamily: 'Tajawal',
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: 'شارك أفكارك مع المجتمع...\n\nيمكنك كتابة:\n• أسئلة أو استفسارات\n• مشاركة خبراتك\n• نقاش موضوع معين\n• قصيدة أو نص أدبي',
              hintStyle: TextStyle(
                color: widget.isDarkMode
                    ? AppTheme.darkSecondaryTextColor
                    : AppTheme.secondaryTextColor,
                fontSize: 14.sp,
                fontFamily: 'Tajawal',
                height: 1.4,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: AppTheme.primaryBrandColor.withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: AppTheme.primaryBrandColor.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: AppTheme.primaryBrandColor,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: widget.isDarkMode
                  ? AppTheme.darkBackgroundColor
                  : Colors.white,
              contentPadding: EdgeInsets.all(16.w),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_contentController.text.length}/1000',
                style: TextStyle(
                  color: _contentController.text.length > 800
                      ? Colors.orange
                      : widget.isDarkMode
                      ? AppTheme.darkSecondaryTextColor
                      : AppTheme.secondaryTextColor,
                  fontSize: 12.sp,
                  fontFamily: 'Tajawal',
                ),
              ),
              Row(
                children: [
                  if (_contentController.text.isNotEmpty) ...[
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 16.r,
                    ),
                    SizedBox(width: 4.w),
                  ],
                  Text(
                    _contentController.text.isEmpty
                        ? 'ابدأ بكتابة منشورك'
                        : 'جاهز للنشر',
                    style: TextStyle(
                      color: _contentController.text.isEmpty
                          ? widget.isDarkMode
                          ? AppTheme.darkSecondaryTextColor
                          : AppTheme.secondaryTextColor
                          : Colors.green,
                      fontSize: 12.sp,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostGuidelines() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.primaryBrandColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppTheme.primaryBrandColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'إرشادات النشر',
                style: TextStyle(
                  color: AppTheme.primaryBrandColor,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Tajawal',
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.info_outline,
                color: AppTheme.primaryBrandColor,
                size: 18.r,
              ),
            ],
          ),
          SizedBox(height: 8.h),
          _buildGuidelineItem('احترم جميع أعضاء المجتمع'),
          _buildGuidelineItem('تأكد من صحة المعلومات قبل المشاركة'),
          _buildGuidelineItem('استخدم لغة مهذبة ومناسبة'),
          _buildGuidelineItem('اختر المجتمع المناسب لموضوعك'),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppTheme.primaryBrandColor.withOpacity(0.8),
                fontSize: 12.sp,
                fontFamily: 'Tajawal',
                height: 1.3,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            margin: EdgeInsets.only(top: 6.h),
            width: 4.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppTheme.primaryBrandColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  bool _canPost() {
    return _contentController.text.trim().isNotEmpty &&
        selectedCategoryId != null &&
        _contentController.text.length <= 1000;
  }

  Future<void> _publishPost(CommunityProvider communityProvider) async {
    if (!_canPost()) return;

    setState(() {
      isPosting = true;
    });

    try {
      final selectedCategory = widget.categories.firstWhere(
            (cat) => cat.id == selectedCategoryId!,
      );

      final success = await communityProvider.createPost(
        content: _contentController.text.trim(),
        category: selectedCategory.name,
      );

      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'تم نشر المنشور بنجاح!',
                  style: TextStyle(fontFamily: 'Tajawal'),
                ),
                SizedBox(width: 8.w),
                Icon(Icons.check_circle, color: Colors.white),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            margin: EdgeInsets.all(16.w),
          ),
        );

        // Navigate back after a short delay
        await Future.delayed(const Duration(milliseconds: 500));
        Navigator.pop(context);
      } else {
        throw Exception(communityProvider.errorMessage ?? 'فشل في نشر المنشور');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'فشل في نشر المنشور: ${e.toString()}',
                style: TextStyle(fontFamily: 'Tajawal'),
              ),
              SizedBox(width: 8.w),
              Icon(Icons.error, color: Colors.white),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          margin: EdgeInsets.all(16.w),
        ),
      );
    } finally {
      setState(() {
        isPosting = false;
      });
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}