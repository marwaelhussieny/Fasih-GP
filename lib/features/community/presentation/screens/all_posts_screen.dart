// lib/features/community/presentation/screens/all_posts_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:grad_project/core/theme/app_theme.dart';
import 'package:grad_project/features/community/presentation/providers/community_provider.dart';
import 'package:grad_project/features/community/presentation/widgets/community_widgets.dart';
import 'package:grad_project/features/community/presentation/screens/create_post_screen.dart';

class AllPostsScreen extends StatefulWidget {
  final bool isDarkMode;

  const AllPostsScreen({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  State<AllPostsScreen> createState() => _AllPostsScreenState();
}

class _AllPostsScreenState extends State<AllPostsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;

  TextEditingController searchController = TextEditingController();
  bool hasMorePosts = true;

  final List<String> sortOptions = [
    'الأحدث',
    'الأقدم',
    'الأكثر تفاعلاً',
    'الأكثر إعجاباً',
    'الأكثر تعليقاً'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    ));

    _fabAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkMode
          ? AppTheme.darkBackgroundColor
          : AppTheme.lightBackgroundColor,
      body: Consumer<CommunityProvider>(
        builder: (context, communityProvider, child) {
          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 140.h,
                  floating: false,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: widget.isDarkMode
                          ? AppTheme.darkPrimaryTextColor
                          : AppTheme.primaryTextColor,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  actions: [
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.sort,
                        color: AppTheme.primaryBrandColor,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      color: widget.isDarkMode
                          ? AppTheme.darkCardColor
                          : AppTheme.cardBackgroundColor,
                      onSelected: (String value) {
                        communityProvider.setFilter(value);
                      },
                      itemBuilder: (BuildContext context) {
                        return sortOptions.map((String option) {
                          return PopupMenuItem<String>(
                            value: option,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  option,
                                  style: TextStyle(
                                    color: widget.isDarkMode
                                        ? AppTheme.darkPrimaryTextColor
                                        : AppTheme.primaryTextColor,
                                    fontFamily: 'Tajawal',
                                    fontSize: 14.sp,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                if (communityProvider.selectedFilter == option)
                                  Icon(
                                    Icons.check,
                                    color: AppTheme.primaryBrandColor,
                                    size: 18.r,
                                  ),
                              ],
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ],
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
                      child: SafeArea(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 20.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8.r),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryBrandColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Icon(
                                    Icons.article_outlined,
                                    color: AppTheme.primaryBrandColor,
                                    size: 24.r,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Text(
                                  'جميع المنشورات',
                                  style: TextStyle(
                                    color: widget.isDarkMode
                                        ? AppTheme.darkPrimaryTextColor
                                        : AppTheme.primaryTextColor,
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Tajawal',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(48.h),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 16.w),
                      decoration: BoxDecoration(
                        color: widget.isDarkMode
                            ? AppTheme.darkCardColor
                            : AppTheme.cardBackgroundColor,
                        borderRadius: BorderRadius.circular(25.r),
                        border: Border.all(
                          color: AppTheme.primaryBrandColor.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(25.r),
                          color: AppTheme.primaryBrandColor,
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: widget.isDarkMode
                            ? AppTheme.darkSecondaryTextColor
                            : AppTheme.secondaryTextColor,
                        labelStyle: TextStyle(
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                        ),
                        unselectedLabelStyle: TextStyle(
                          fontFamily: 'Tajawal',
                          fontWeight: FontWeight.w500,
                          fontSize: 12.sp,
                        ),
                        tabs: [
                          Tab(text: 'الكل'),
                          Tab(text: 'شعر'),
                          Tab(text: 'تعليم'),
                          Tab(text: 'أدب'),
                        ],
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: Column(
              children: [
                // Search Bar
                Container(
                  margin: EdgeInsets.all(16.w),
                  child: TextField(
                    controller: searchController,
                    textAlign: TextAlign.right,
                    onChanged: (value) {
                      communityProvider.setSearchQuery(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'البحث في المنشورات...',
                      hintStyle: TextStyle(
                        color: widget.isDarkMode
                            ? AppTheme.darkSecondaryTextColor
                            : AppTheme.secondaryTextColor,
                        fontSize: 14.sp,
                        fontFamily: 'Tajawal',
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: widget.isDarkMode
                            ? AppTheme.darkSecondaryTextColor
                            : AppTheme.secondaryTextColor,
                      ),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          communityProvider.setSearchQuery('');
                        },
                      )
                          : null,
                      filled: true,
                      fillColor: widget.isDarkMode
                          ? AppTheme.darkCardColor
                          : AppTheme.cardBackgroundColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: widget.isDarkMode
                              ? AppTheme.primaryBrandColor.withOpacity(0.2)
                              : AppTheme.primaryBrandColor.withOpacity(0.1),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: widget.isDarkMode
                              ? AppTheme.primaryBrandColor.withOpacity(0.2)
                              : AppTheme.primaryBrandColor.withOpacity(0.1),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: AppTheme.primaryBrandColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),

                // Posts List
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPostsList(communityProvider, 'all'),
                      _buildPostsList(communityProvider, 'poetry'),
                      _buildPostsList(communityProvider, 'education'),
                      _buildPostsList(communityProvider, 'literature'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabScaleAnimation,
        child: FloatingActionButton.extended(
          onPressed: () => _navigateToCreatePost(),
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
      ),
    );
  }

  Widget _buildPostsList(CommunityProvider communityProvider, String category) {
    final posts = communityProvider.filteredPosts;

    if (communityProvider.isLoading) {
      return _buildLoadingState();
    }

    if (communityProvider.hasError) {
      return _buildErrorState(communityProvider);
    }

    if (posts.isEmpty) {
      return _buildEmptyState(communityProvider);
    }

    return RefreshIndicator(
      onRefresh: () => communityProvider.refreshData(),
      color: AppTheme.primaryBrandColor,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: posts.length + (hasMorePosts ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == posts.length) {
            return _buildLoadMoreButton();
          }

          final post = posts[index];
          return AnimatedContainer(
            duration: Duration(milliseconds: 200 + (index * 50)),
            margin: EdgeInsets.only(bottom: 16.h),
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
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 64.r,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'حدث خطأ في تحميل المنشورات',
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
          ElevatedButton.icon(
            onPressed: () => communityProvider.refreshData(),
            icon: Icon(Icons.refresh),
            label: Text(
              'إعادة المحاولة',
              style: TextStyle(fontFamily: 'Tajawal'),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBrandColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(CommunityProvider communityProvider) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: AppTheme.primaryBrandColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                communityProvider.searchQuery.isNotEmpty
                    ? Icons.search_off_rounded
                    : Icons.article_outlined,
                size: 64.r,
                color: AppTheme.primaryBrandColor,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              communityProvider.searchQuery.isNotEmpty
                  ? 'لم نجد منشورات تطابق بحثك'
                  : 'لا توجد منشورات',
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
              communityProvider.searchQuery.isNotEmpty
                  ? 'جرب البحث بكلمات مختلفة'
                  : 'كن أول من يشارك منشوراً',
              style: TextStyle(
                color: widget.isDarkMode
                    ? AppTheme.darkSecondaryTextColor
                    : AppTheme.secondaryTextColor,
                fontSize: 14.sp,
                fontFamily: 'Tajawal',
              ),
              textAlign: TextAlign.center,
            ),
            if (communityProvider.searchQuery.isNotEmpty) ...[
              SizedBox(height: 20.h),
              TextButton.icon(
                onPressed: () {
                  communityProvider.setSearchQuery('');
                  searchController.clear();
                },
                icon: Icon(Icons.clear),
                label: Text(
                  'مسح البحث',
                  style: TextStyle(
                    color: AppTheme.primaryBrandColor,
                    fontSize: 14.sp,
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ] else ...[
              SizedBox(height: 20.h),
              ElevatedButton.icon(
                onPressed: () => _navigateToCreatePost(),
                icon: Icon(Icons.add),
                label: Text(
                  'إنشاء منشور',
                  style: TextStyle(fontFamily: 'Tajawal'),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBrandColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16.h),
      child: OutlinedButton(
        onPressed: _loadMorePosts,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: AppTheme.primaryBrandColor,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 12.h),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.keyboard_arrow_down,
              color: AppTheme.primaryBrandColor,
              size: 20.r,
            ),
            SizedBox(width: 8.w),
            Text(
              'تحميل المزيد',
              style: TextStyle(
                color: AppTheme.primaryBrandColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'Tajawal',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCreatePost() {
    final communityProvider = context.read<CommunityProvider>();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => CreatePostScreen(
          isDarkMode: widget.isDarkMode,
          categories: communityProvider.categories,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
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
    ).then((_) {
      // Refresh data when returning from create post
      communityProvider.refreshData();
    });
  }

  Future<void> _loadMorePosts() async {
    // Simulate loading more posts
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      hasMorePosts = false; // For demo, set to false after first load
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fabAnimationController.dispose();
    searchController.dispose();
    super.dispose();
  }
}