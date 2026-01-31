// lib/features/community/presentation/widgets/post_card_updated.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grad_project/core/theme/app_theme.dart';
import 'package:grad_project/features/community/data/models/community_models.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grad_project/core/theme/app_theme.dart';
import 'package:grad_project/features/community/data/models/community_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:grad_project/core/theme/app_theme.dart';
import 'package:grad_project/features/community/presentation/providers/community_provider.dart';
import 'package:grad_project/features/community/data/models/community_models.dart';

class PostCardUpdated extends StatefulWidget {
  final CommunityPost post;
  final bool isDarkMode;
  final VoidCallback onLike;
  final Function(String) onComment;

  const PostCardUpdated({
    Key? key,
    required this.post,
    required this.isDarkMode,
    required this.onLike,
    required this.onComment,
  }) : super(key: key);

  @override
  State<PostCardUpdated> createState() => _PostCardUpdatedState();
}

class _PostCardUpdatedState extends State<PostCardUpdated> {
  final TextEditingController _commentController = TextEditingController();
  bool _showCommentInput = false;

  @override
  Widget build(BuildContext context) {
    // Configure Arabic timeago
    timeago.setLocaleMessages('ar', timeago.ArMessages());

    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // User Info Header
          _buildUserHeader(),
          SizedBox(height: 12.h),

          // Post Content
          _buildPostContent(),
          SizedBox(height: 12.h),

          // Action Buttons
          _buildActionButtons(),

          // Comments Section
          if (widget.post.comments.isNotEmpty) _buildCommentsSection(),

          // Comment Input
          if (_showCommentInput) _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                widget.post.createdByName ?? 'مستخدم مجهول',
                style: TextStyle(
                  color: widget.isDarkMode
                      ? Colors.white
                      : const Color(0xFF2C2C2C),
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                  fontFamily: 'Tajawal',
                ),
                textAlign: TextAlign.right,
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    timeago.format(widget.post.createdAt, locale: 'ar'),
                    style: TextStyle(
                      color: widget.isDarkMode
                          ? const Color(0xFF9E9E9E)
                          : const Color(0xFF757575),
                      fontSize: 11.sp,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  Text(
                    ' • ',
                    style: TextStyle(
                      color: widget.isDarkMode
                          ? const Color(0xFF9E9E9E)
                          : const Color(0xFF757575),
                      fontSize: 11.sp,
                    ),
                  ),
                  Text(
                    'نشر في ${widget.post.category}',
                    style: TextStyle(
                      color: const Color(0xFFFF7F50),
                      fontSize: 11.sp,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(width: 10.w),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFFF7F50).withOpacity(0.3),
              width: 1.5.w,
            ),
          ),
          child: CircleAvatar(
            radius: 18.r,
            backgroundColor: const Color(0xFFFF7F50).withOpacity(0.1),
            child: Text(
              (widget.post.createdByName?.isNotEmpty ?? false)
                  ? widget.post.createdByName!.substring(0, 1)
                  : 'م',
              style: TextStyle(
                color: const Color(0xFFFF7F50),
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPostContent() {
    return Text(
      widget.post.content,
      textAlign: TextAlign.right,
      style: TextStyle(
        color: widget.isDarkMode
            ? Colors.white
            : const Color(0xFF2C2C2C),
        fontSize: 14.sp,
        fontFamily: 'Tajawal',
        height: 1.5,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Share Button
        _buildActionButton(
          icon: Icons.share,
          label: 'نشر',
          color: widget.isDarkMode
              ? const Color(0xFF9E9E9E)
              : const Color(0xFF757575),
          onTap: () {
            // TODO: Implement share functionality
          },
        ),

        // Likes and Comments
        Row(
          children: [
            _buildActionButton(
              icon: Icons.chat_bubble_outline,
              label: '${widget.post.commentsCount}',
              color: widget.isDarkMode
                  ? const Color(0xFF9E9E9E)
                  : const Color(0xFF757575),
              onTap: () {
                setState(() {
                  _showCommentInput = !_showCommentInput;
                });
              },
            ),
            SizedBox(width: 12.w),
            _buildActionButton(
              icon: widget.post.isLiked ? Icons.favorite : Icons.favorite_border,
              label: '${widget.post.likesCount}',
              color: widget.post.isLiked ? Colors.red : (widget.isDarkMode
                  ? const Color(0xFF9E9E9E)
                  : const Color(0xFF757575)),
              onTap: widget.onLike,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: widget.isDarkMode
              ? const Color(0xFF404040).withOpacity(0.5)
              : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.w,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 16.r,
            ),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                color: widget.isDarkMode
                    ? Colors.white
                    : const Color(0xFF2C2C2C),
                fontSize: 12.sp,
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsSection() {
    return Container(
      margin: EdgeInsets.only(top: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: widget.isDarkMode
            ? const Color(0xFF404040).withOpacity(0.3)
            : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'التعليقات',
            style: TextStyle(
              color: widget.isDarkMode
                  ? Colors.white
                  : const Color(0xFF2C2C2C),
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
          ),
          SizedBox(height: 8.h),
          ...widget.post.comments.take(3).map((comment) => _buildCommentItem(comment)),
          if (widget.post.comments.length > 3)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text(
                'عرض ${widget.post.comments.length - 3} تعليقات أخرى',
                style: TextStyle(
                  color: const Color(0xFFFF7F50),
                  fontSize: 11.sp,
                  fontFamily: 'Tajawal',
                ),
                textAlign: TextAlign.right,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(CommunityComment comment) {
    return Container(
      margin: EdgeInsets.only(bottom: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  comment.userName,
                  style: TextStyle(
                    color: const Color(0xFFFF7F50),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tajawal',
                  ),
                  textAlign: TextAlign.right,
                ),
                SizedBox(height: 2.h),
                Text(
                  comment.text,
                  style: TextStyle(
                    color: widget.isDarkMode
                        ? Colors.white
                        : const Color(0xFF2C2C2C),
                    fontSize: 12.sp,
                    fontFamily: 'Tajawal',
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          CircleAvatar(
            radius: 12.r,
            backgroundColor: const Color(0xFFFF7F50).withOpacity(0.1),
            child: Text(
              comment.userName.isNotEmpty ? comment.userName.substring(0, 1) : 'م',
              style: TextStyle(
                color: const Color(0xFFFF7F50),
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      margin: EdgeInsets.only(top: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: widget.isDarkMode
            ? const Color(0xFF404040).withOpacity(0.3)
            : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (_commentController.text.trim().isNotEmpty) {
                widget.onComment(_commentController.text.trim());
                _commentController.clear();
                setState(() {
                  _showCommentInput = false;
                });
              }
            },
            icon: Icon(
              Icons.send,
              color: const Color(0xFFFF7F50),
              size: 20.r,
            ),
          ),
          Expanded(
            child: TextField(
              controller: _commentController,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: widget.isDarkMode
                    ? Colors.white
                    : const Color(0xFF2C2C2C),
                fontFamily: 'Tajawal',
              ),
              decoration: InputDecoration(
                hintText: 'اكتب تعليقك...',
                hintStyle: TextStyle(
                  color: widget.isDarkMode
                      ? const Color(0xFF9E9E9E)
                      : const Color(0xFF757575),
                  fontFamily: 'Tajawal',
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
              ),
              maxLines: null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}

// lib/features/community/presentation/widgets/community_header_stats_updated.dart



class CommunityHeaderStatsUpdated extends StatelessWidget {
  final bool isDarkMode;
  final CommunityStats? stats;

  const CommunityHeaderStatsUpdated({
    Key? key,
    required this.isDarkMode,
    this.stats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultStats = CommunityStats();
    final currentStats = stats ?? defaultStats;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color(0xFF2A2A2A)
            : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDarkMode
              ? const Color(0xFF404040)
              : const Color(0xFFE0E0E0),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            icon: Icons.bookmark_outline,
            value: '${currentStats.savedPosts}',
            label: 'مفضل',
            color: const Color(0xFF2196F3),
            isDarkMode: isDarkMode,
          ),
          _buildDivider(),
          _buildStatItem(
            icon: Icons.flash_on_outlined,
            value: '${currentStats.totalInteractions}',
            label: 'مشاركة',
            color: const Color(0xFFFFC107),
            isDarkMode: isDarkMode,
          ),
          _buildDivider(),
          _buildStatItem(
            icon: Icons.local_fire_department_outlined,
            value: '${currentStats.activePosts}',
            label: 'نشط',
            color: const Color(0xFFFF9800),
            isDarkMode: isDarkMode,
          ),
          _buildDivider(),
          _buildStatItem(
            icon: Icons.people_outline,
            value: '${currentStats.totalMembers}',
            label: 'عضو',
            color: const Color(0xFF4CAF50),
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required bool isDarkMode,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20.r,
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              color: isDarkMode
                  ? Colors.white
                  : const Color(0xFF2C2C2C),
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: isDarkMode
                  ? const Color(0xFF9E9E9E)
                  : const Color(0xFF757575),
              fontSize: 12.sp,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30.h,
      width: 1.w,
      color: isDarkMode
          ? const Color(0xFF404040)
          : const Color(0xFFE0E0E0),
    );
  }
}

// lib/features/community/presentation/screens/create_post_screen_updated.dart



class CreatePostScreenUpdated extends StatefulWidget {
  final bool isDarkMode;
  final List<CommunityCategory> categories;

  const CreatePostScreenUpdated({
    Key? key,
    required this.isDarkMode,
    required this.categories,
  }) : super(key: key);

  @override
  State<CreatePostScreenUpdated> createState() => _CreatePostScreenUpdatedState();
}

class _CreatePostScreenUpdatedState extends State<CreatePostScreenUpdated>
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
                child: Text(
                  category.name,
                  textAlign: TextAlign.right,
                  style: TextStyle(fontFamily: 'Tajawal'),
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
          SizedBox(height: 12.h),
          TextField(
            controller: _contentController,
            maxLines: 8,
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
              hintText: 'اكتب منشورك هنا...',
              hintStyle: TextStyle(
                color: widget.isDarkMode
                    ? AppTheme.darkSecondaryTextColor
                    : AppTheme.secondaryTextColor,
                fontSize: 16.sp,
                fontFamily: 'Tajawal',
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
            ),
          ),
        ],
      ),
    );
  }

  bool _canPost() {
    return _contentController.text.trim().isNotEmpty &&
        selectedCategoryId != null;
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
            content: Text(
              'تم نشر المنشور بنجاح!',
              style: TextStyle(fontFamily: 'Tajawal'),
              textAlign: TextAlign.right,
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        );

        Navigator.pop(context);
      } else {
        throw Exception(communityProvider.errorMessage ?? 'فشل في نشر المنشور');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'فشل في نشر المنشور: ${e.toString()}',
            style: TextStyle(fontFamily: 'Tajawal'),
            textAlign: TextAlign.right,
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
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