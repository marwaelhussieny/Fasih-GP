// lib/features/community/presentation/screens/community_main_feed_tab_updated.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:grad_project/core/theme/app_theme.dart';
import 'package:grad_project/features/community/presentation/providers/community_provider.dart';
import 'package:grad_project/features/community/presentation/widgets/community_widgets.dart';
import 'package:grad_project/features/community/presentation/screens/all_posts_screen.dart';

class CommunityMainFeedTabUpdated extends StatefulWidget {
  final bool isDarkMode;

  const CommunityMainFeedTabUpdated({
    Key? key,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<CommunityMainFeedTabUpdated> createState() => _CommunityMainFeedTabUpdatedState();
}

class _CommunityMainFeedTabUpdatedState extends State<CommunityMainFeedTabUpdated>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> filters = ['الأحدث', 'الأكثر تفاعلاً', 'مجتمعاتي', 'المحفوظة'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Consumer<CommunityProvider>(
          builder: (context, communityProvider, child) {
            return RefreshIndicator(
              onRefresh: () => communityProvider.refreshData(),
              color: AppTheme.primaryBrandColor,
              backgroundColor: widget.isDarkMode
                  ? AppTheme.darkCardColor
                  : AppTheme.cardBackgroundColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 8.h),

                    // Header Stats
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      child: CommunityHeaderStatsUpdated(
                        isDarkMode: widget.isDarkMode,
                        stats: communityProvider.stats,
                      ),
                    ),

                    // Filter Chips
                    _buildFilterChips(communityProvider),

                    // Posts Section Header
                    _buildPostsHeader(),

                    // Content based on loading state
                    if (communityProvider.isLoading)
                      _buildLoadingState()
                    else if (communityProvider.hasError)
                      _buildErrorState(communityProvider)
                    else if (communityProvider.recentPosts.isEmpty)
                        _buildEmptyState()
                      else
                        _buildPostsList(communityProvider),

                    SizedBox(height: 100.h), // Space for FAB
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterChips(CommunityProvider communityProvider) {
    return Container(
      height: 50.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        reverse: true,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = communityProvider.selectedFilter == filter;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: EdgeInsets.only(left: 8.w),
            child: FilterChip(
              selected: isSelected,
              label: Text(
                filter,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : (widget.isDarkMode
                      ? AppTheme.darkPrimaryTextColor
                      : AppTheme.primaryTextColor),
                  fontSize: 12.sp,
                  fontFamily: 'Tajawal',
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              onSelected: (bool selected) {
                communityProvider.setFilter(filter);
              },
              backgroundColor: widget.isDarkMode
                  ? AppTheme.darkCardColor
                  : AppTheme.cardBackgroundColor,
              selectedColor: AppTheme.primaryBrandColor,
              checkmarkColor: Colors.white,
              side: BorderSide(
                color: isSelected
                    ? AppTheme.primaryBrandColor
                    : (widget.isDarkMode
                    ? AppTheme.primaryBrandColor.withOpacity(0.3)
                    : AppTheme.primaryBrandColor.withOpacity(0.2)),
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostsHeader() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => _navigateToAllPosts(),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppTheme.primaryBrandColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: AppTheme.primaryBrandColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'عرض الكل',
                    style: TextStyle(
                      color: AppTheme.primaryBrandColor,
                      fontSize: 14.sp,
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppTheme.primaryBrandColor,
                    size: 14.r,
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              Text(
                'آخر المنشورات',
                style: TextStyle(
                  color: widget.isDarkMode
                      ? AppTheme.darkPrimaryTextColor
                      : AppTheme.primaryTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                  fontFamily: 'Tajawal',
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBrandColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.article_outlined,
                  color: AppTheme.primaryBrandColor,
                  size: 20.r,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: EdgeInsets.all(40.w),
      child: Column(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBrandColor),
          ),
          SizedBox(height: 16.h),
          Text(
            'جاري تحميل المنشورات...',
            style: TextStyle(
              color: widget.isDarkMode
                  ? AppTheme.darkSecondaryTextColor
                  : AppTheme.secondaryTextColor,
              fontSize: 14.sp,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(CommunityProvider communityProvider) {
    return Container(
      padding: EdgeInsets.all(40.w),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 64.r,
            color: Colors.red,
          ),
          SizedBox(height: 16.h),
          Text(
            'حدث خطأ في تحميل المنشورات',
            style: TextStyle(
              color: widget.isDarkMode
                  ? AppTheme.darkPrimaryTextColor
                  : AppTheme.primaryTextColor,
              fontSize: 16.sp,
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            communityProvider.errorMessage ?? 'خطأ غير معروف',
            style: TextStyle(
              color: widget.isDarkMode
                  ? AppTheme.darkSecondaryTextColor
                  : AppTheme.secondaryTextColor,
              fontSize: 14.sp,
              fontFamily: 'Tajawal',
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),
          ElevatedButton(
            onPressed: () => communityProvider.refreshData(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBrandColor,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'إعادة المحاولة',
              style: TextStyle(fontFamily: 'Tajawal'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(40.w),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: AppTheme.primaryBrandColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.article_outlined,
              size: 64.r,
              color: AppTheme.primaryBrandColor,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'لا توجد منشورات حتى الآن',
            style: TextStyle(
              color: widget.isDarkMode
                  ? AppTheme.darkPrimaryTextColor
                  : AppTheme.primaryTextColor,
              fontSize: 18.sp,
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'كن أول من يشارك منشوراً في المجتمع',
            style: TextStyle(
              color: widget.isDarkMode
                  ? AppTheme.darkSecondaryTextColor
                  : AppTheme.secondaryTextColor,
              fontSize: 14.sp,
              fontFamily: 'Tajawal',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPostsList(CommunityProvider communityProvider) {
    return Column(
      children: communityProvider.recentPosts.asMap().entries.map((entry) {
        int index = entry.key;
        final post = entry.value;

        return AnimatedContainer(
          duration: Duration(milliseconds: 200 + (index * 100)),
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: widget.isDarkMode
                ? AppTheme.darkCardColor
                : AppTheme.cardBackgroundColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: widget.isDarkMode
                  ? AppTheme.primaryBrandColor.withOpacity(0.2)
                  : AppTheme.primaryBrandColor.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isDarkMode
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: PostCardUpdated(
            post: post,
            isDarkMode: widget.isDarkMode,
            onLike: () => communityProvider.togglePostLike(post.id),
            onComment: (text) => communityProvider.addComment(post.id, text),
          ),
        );
      }).toList(),
    );
  }

  void _navigateToAllPosts() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => AllPostsScreen(
          isDarkMode: widget.isDarkMode,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}