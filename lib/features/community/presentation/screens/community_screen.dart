// lib/features/community/presentation/screens/community_main_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:grad_project/core/theme/app_theme.dart';
import 'package:grad_project/features/community/presentation/providers/community_provider.dart';
import 'package:grad_project/features/community/presentation/screens/create_post_screen.dart';
import 'package:grad_project/features/community/presentation/screens/all_posts_screen.dart';

class CommunityMainScreen extends StatefulWidget {
  const CommunityMainScreen({Key? key}) : super(key: key);

  @override
  State<CommunityMainScreen> createState() => _CommunityMainScreenState();
}

class _CommunityMainScreenState extends State<CommunityMainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load community data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityProvider>().loadCommunityData();
    });
  }

  @override
  Widget build(BuildContext context) {
    isDarkMode = Theme.of(context).brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: isDarkMode ? AppTheme.darkBackgroundColor : AppTheme.lightBackgroundColor,
      body: Consumer<CommunityProvider>(
        builder: (context, communityProvider, child) {
          return SafeArea(
            top: true,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 180.h,
                    floating: false,
                    pinned: true,
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    automaticallyImplyLeading: false,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppTheme.primaryBrandColor.withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(top: 40.h),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(height: 20.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10.r),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryBrandColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(14.r),
                                    ),
                                    child: Icon(
                                      Icons.groups_rounded,
                                      color: AppTheme.primaryBrandColor,
                                      size: 26.r,
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                  Text(
                                    'المجتمع',
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? AppTheme.darkPrimaryTextColor
                                          : AppTheme.primaryTextColor,
                                      fontSize: 26.sp,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Tajawal',
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 24.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                    bottom: PreferredSize(
                      preferredSize: Size.fromHeight(60.h),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: isDarkMode ? AppTheme.darkCardColor : AppTheme.cardBackgroundColor,
                          borderRadius: BorderRadius.circular(25.r),
                          border: Border.all(
                            color: AppTheme.primaryBrandColor.withOpacity(0.2),
                            width: 1,
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
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(25.r),
                            color: AppTheme.primaryBrandColor,
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: isDarkMode
                              ? AppTheme.darkSecondaryTextColor
                              : AppTheme.secondaryTextColor,
                          labelStyle: TextStyle(
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                          ),
                          unselectedLabelStyle: TextStyle(
                            fontFamily: 'Tajawal',
                            fontWeight: FontWeight.w500,
                            fontSize: 14.sp,
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          tabs: [
                            Tab(
                              height: 44.h,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.article_outlined, size: 18.r),
                                  SizedBox(width: 6.w),
                                  Text('الأخبار'),
                                ],
                              ),
                            ),
                            Tab(
                              height: 44.h,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.groups_outlined, size: 18.r),
                                  SizedBox(width: 6.w),
                                  Text('المجتمعات'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildFeedTab(),
                  _buildCommunitiesTab(),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: Consumer<CommunityProvider>(
        builder: (context, communityProvider, child) {
          return AnimatedScale(
            scale: 1.0,
            duration: const Duration(milliseconds: 200),
            child: FloatingActionButton.extended(
              onPressed: () => _navigateToCreatePost(communityProvider),
              backgroundColor: AppTheme.primaryBrandColor,
              foregroundColor: Colors.white,
              elevation: 8,
              label: Row(
                children: [
                  Icon(Icons.add, size: 20.r),
                  SizedBox(width: 8.w),
                  Text(
                    'منشور جديد',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeedTab() {
    return Consumer<CommunityProvider>(
      builder: (context, communityProvider, child) {
        return RefreshIndicator(
          onRefresh: () => communityProvider.refreshData(),
          color: AppTheme.primaryBrandColor,
          backgroundColor: isDarkMode
              ? AppTheme.darkCardColor
              : AppTheme.cardBackgroundColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 8.h),

                // Header Stats
                _buildHeaderStats(),

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

                SizedBox(height: 100.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCommunitiesTab() {
    return Consumer<CommunityProvider>(
      builder: (context, communityProvider, child) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 16.h),

                // Create New Community Button
                _buildCreateCommunityButton(communityProvider),
                SizedBox(height: 20.h),

                // Communities Section Header
                _buildCommunitiesHeader(),
                SizedBox(height: 16.h),

                // Communities List
                if (communityProvider.isLoading)
                  _buildLoadingState()
                else if (communityProvider.hasError)
                  _buildErrorState(communityProvider)
                else if (communityProvider.categories.isEmpty)
                    _buildEmptyCommunitiesState()
                  else
                    _buildCommunitiesList(communityProvider),

                SizedBox(height: 20.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderStats() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: isDarkMode ? AppTheme.darkCardColor : AppTheme.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDarkMode
              ? AppTheme.primaryBrandColor.withOpacity(0.2)
              : AppTheme.primaryBrandColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(Icons.bookmark_outline, '1', 'مفضل'),
          _buildDivider(),
          _buildStatItem(Icons.flash_on_outlined, '2,542', 'مشاركة'),
          _buildDivider(),
          _buildStatItem(Icons.local_fire_department_outlined, '3', 'نشط'),
          _buildDivider(),
          _buildStatItem(Icons.people_outline, '226', 'عضو'),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryBrandColor, size: 20.r),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              color: isDarkMode ? AppTheme.darkPrimaryTextColor : AppTheme.primaryTextColor,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: isDarkMode ? AppTheme.darkSecondaryTextColor : AppTheme.secondaryTextColor,
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
          ? AppTheme.darkSecondaryTextColor.withOpacity(0.3)
          : AppTheme.secondaryTextColor.withOpacity(0.3),
    );
  }

  Widget _buildFilterChips(CommunityProvider communityProvider) {
    final filters = ['الأحدث', 'الأكثر تفاعلاً', 'مجتمعاتي', 'المحفوظة'];

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

          return Container(
            margin: EdgeInsets.only(left: 8.w),
            child: FilterChip(
              selected: isSelected,
              label: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.primaryBrandColor,
                  fontSize: 12.sp,
                  fontFamily: 'Tajawal',
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              onSelected: (bool selected) {
                communityProvider.setFilter(filter);
              },
              backgroundColor: AppTheme.primaryBrandColor.withOpacity(0.1),
              selectedColor: AppTheme.primaryBrandColor,
              checkmarkColor: Colors.white,
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
                  color: isDarkMode ? AppTheme.darkPrimaryTextColor : AppTheme.primaryTextColor,
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
            'جاري تحميل البيانات...',
            style: TextStyle(
              color: isDarkMode ? AppTheme.darkSecondaryTextColor : AppTheme.secondaryTextColor,
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
          Icon(Icons.error_outline, size: 64.r, color: Colors.red),
          SizedBox(height: 16.h),
          Text(
            'حدث خطأ في تحميل البيانات',
            style: TextStyle(
              color: isDarkMode ? AppTheme.darkPrimaryTextColor : AppTheme.primaryTextColor,
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
              color: isDarkMode ? AppTheme.darkSecondaryTextColor : AppTheme.secondaryTextColor,
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
            child: Text('إعادة المحاولة', style: TextStyle(fontFamily: 'Tajawal')),
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
              color: isDarkMode ? AppTheme.darkPrimaryTextColor : AppTheme.primaryTextColor,
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
              color: isDarkMode ? AppTheme.darkSecondaryTextColor : AppTheme.secondaryTextColor,
              fontSize: 14.sp,
              fontFamily: 'Tajawal',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCommunitiesState() {
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
              Icons.groups_outlined,
              size: 64.r,
              color: AppTheme.primaryBrandColor,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'لا توجد مجتمعات حتى الآن',
            style: TextStyle(
              color: isDarkMode ? AppTheme.darkPrimaryTextColor : AppTheme.primaryTextColor,
              fontSize: 18.sp,
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'كن أول من ينشئ مجتمعاً جديداً',
            style: TextStyle(
              color: isDarkMode ? AppTheme.darkSecondaryTextColor : AppTheme.secondaryTextColor,
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
      children: communityProvider.recentPosts.take(5).map((post) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isDarkMode ? AppTheme.darkCardColor : AppTheme.cardBackgroundColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDarkMode
                  ? AppTheme.primaryBrandColor.withOpacity(0.2)
                  : AppTheme.primaryBrandColor.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: _buildPostCard(post, communityProvider),
        );
      }).toList(),
    );
  }

  Widget _buildCommunitiesList(CommunityProvider communityProvider) {
    return Column(
      children: communityProvider.categories.map((category) {
        return Container(
          margin: EdgeInsets.only(bottom: 16.h),
          child: _buildCommunityCard(category, () {
            communityProvider.loadPostsByCategory(category.name);
          }),
        );
      }).toList(),
    );
  }

  Widget _buildPostCard(post, CommunityProvider communityProvider) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // User header
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      post.createdByName ?? 'مستخدم مجهول',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                        fontFamily: 'Tajawal',
                      ),
                      textAlign: TextAlign.right,
                    ),
                    Text(
                      'نشر في ${post.category}',
                      style: TextStyle(
                        color: AppTheme.primaryBrandColor,
                        fontSize: 11.sp,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              CircleAvatar(
                radius: 18.r,
                backgroundColor: AppTheme.primaryBrandColor.withOpacity(0.1),
                child: Text(
                  (post.createdByName?.isNotEmpty ?? false)
                      ? post.createdByName!.substring(0, 1)
                      : 'م',
                  style: TextStyle(
                    color: AppTheme.primaryBrandColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Post content
          Text(
            post.content,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black87,
              fontSize: 14.sp,
              fontFamily: 'Tajawal',
              height: 1.5,
            ),
          ),
          SizedBox(height: 12.h),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.share, size: 16.r, color: Colors.grey),
                      SizedBox(width: 4.w),
                      Text('نشر', style: TextStyle(fontSize: 12.sp, fontFamily: 'Tajawal')),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chat_bubble_outline, size: 16.r, color: Colors.grey),
                          SizedBox(width: 4.w),
                          Text('${post.commentsCount}', style: TextStyle(fontSize: 12.sp, fontFamily: 'Tajawal')),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  GestureDetector(
                    onTap: () => communityProvider.togglePostLike(post.id),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: post.isLiked ? Colors.red.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            post.isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 16.r,
                            color: post.isLiked ? Colors.red : Colors.grey,
                          ),
                          SizedBox(width: 4.w),
                          Text('${post.likesCount}', style: TextStyle(fontSize: 12.sp, fontFamily: 'Tajawal')),
                        ],
                      ),
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

  Widget _buildCommunityCard(category, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDarkMode ? AppTheme.darkCardColor : AppTheme.cardBackgroundColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDarkMode
                ? AppTheme.primaryBrandColor.withOpacity(0.2)
                : AppTheme.primaryBrandColor.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppTheme.primaryBrandColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: AppTheme.primaryBrandColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                'انضمام',
                style: TextStyle(
                  color: AppTheme.primaryBrandColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
            Spacer(),
            Expanded(
              flex: 3,
              child: Text(
                category.name,
                style: TextStyle(
                  color: isDarkMode ? AppTheme.darkPrimaryTextColor : AppTheme.primaryTextColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Tajawal',
                ),
                textAlign: TextAlign.right,
              ),
            ),
            Container(
              width: 50.w,
              height: 50.h,
              decoration: BoxDecoration(
                color: AppTheme.primaryBrandColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppTheme.primaryBrandColor.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  category.name.isNotEmpty ? category.name.substring(0, 1) : 'م',
                  style: TextStyle(
                    color: AppTheme.primaryBrandColor,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateCommunityButton(CommunityProvider communityProvider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryBrandColor, AppTheme.primaryBrandColor.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBrandColor.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => _showCreateCommunityDialog(communityProvider),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 18.h),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 24.r),
            SizedBox(width: 12.w),
            Text(
              'إنشاء مجتمع جديد',
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
    );
  }

  Widget _buildCommunitiesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () {
            // Navigate to all communities screen
          },
          child: Text(
            'عرض الكل',
            style: TextStyle(
              color: AppTheme.primaryBrandColor,
              fontSize: 14.sp,
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Row(
          children: [
            Text(
              'المجتمعات المتاحة',
              style: TextStyle(
                color: isDarkMode ? AppTheme.darkPrimaryTextColor : AppTheme.primaryTextColor,
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
                Icons.groups_outlined,
                color: AppTheme.primaryBrandColor,
                size: 20.r,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showCreateCommunityDialog(CommunityProvider communityProvider) {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? AppTheme.darkCardColor : AppTheme.cardBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Text(
            'إنشاء مجتمع جديد',
            style: TextStyle(
              color: isDarkMode ? AppTheme.darkPrimaryTextColor : AppTheme.primaryTextColor,
              fontSize: 18.sp,
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'اسم المجتمع',
                style: TextStyle(
                  color: isDarkMode ? AppTheme.darkPrimaryTextColor : AppTheme.primaryTextColor,
                  fontSize: 14.sp,
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: nameController,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: isDarkMode ? AppTheme.darkPrimaryTextColor : AppTheme.primaryTextColor,
                  fontFamily: 'Tajawal',
                ),
                decoration: InputDecoration(
                  hintText: 'أدخل اسم المجتمع...',
                  hintStyle: TextStyle(
                    color: isDarkMode ? AppTheme.darkSecondaryTextColor : AppTheme.secondaryTextColor,
                    fontFamily: 'Tajawal',
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppTheme.primaryBrandColor.withOpacity(0.3)),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'إلغاء',
                style: TextStyle(
                  color: isDarkMode ? AppTheme.darkSecondaryTextColor : AppTheme.secondaryTextColor,
                  fontSize: 14.sp,
                  fontFamily: 'Tajawal',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isNotEmpty) {
                  final success = await communityProvider.createCategory(nameController.text.trim());
                  if (success) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'تم إنشاء المجتمع بنجاح!',
                          style: TextStyle(fontFamily: 'Tajawal'),
                          textAlign: TextAlign.right,
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBrandColor,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'إنشاء',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToCreatePost(CommunityProvider communityProvider) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePostScreen(
          isDarkMode: isDarkMode,
          categories: communityProvider.categories,
        ),
      ),
    ).then((_) {
      communityProvider.refreshData();
    });
  }

  void _navigateToAllPosts() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllPostsScreen(isDarkMode: isDarkMode),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}