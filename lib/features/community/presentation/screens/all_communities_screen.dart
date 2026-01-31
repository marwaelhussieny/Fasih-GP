// lib/features/community/presentation/screens/all_communities_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grad_project/core/theme/app_theme.dart';

class AllCommunitiesScreen extends StatefulWidget {
  final bool isDarkMode;

  const AllCommunitiesScreen({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  State<AllCommunitiesScreen> createState() => _AllCommunitiesScreenState();
}

class _AllCommunitiesScreenState extends State<AllCommunitiesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  String selectedCategory = 'الكل';

  final List<String> categories = [
    'الكل',
    'أدب وشعر',
    'قواعد ونحو',
    'إبداع أدبي',
    'علوم البلاغة',
    'تعليم النحو',
    'أدب كلاسيكي',
    'كتابة إبداعية',
    'فنون الخط',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> allCommunities = [ /* your community data */ ];

    return Scaffold(
      backgroundColor: widget.isDarkMode ? AppTheme.darkBackgroundColor : AppTheme.lightBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: widget.isDarkMode
                  ? AppTheme.darkPrimaryTextColor
                  : AppTheme.primaryTextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'جميع المجتمعات',
          style: TextStyle(
            color: widget.isDarkMode
                ? AppTheme.darkPrimaryTextColor
                : AppTheme.primaryTextColor,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'Tajawal',
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: AppTheme.primaryBrandColor,),
            onPressed: _showFilterDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryBrandColor,
          labelColor: AppTheme.primaryBrandColor,
          unselectedLabelColor: widget.isDarkMode
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
          tabs: [
            Tab(text: 'الكل'),
            Tab(text: 'منضم'),
            Tab(text: 'الأشهر'),
            Tab(text: 'الجديد'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            margin: EdgeInsets.all(16.w),
            child: TextField(
              controller: searchController,
              textAlign: TextAlign.right,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'البحث في المجتمعات...',
                hintStyle: TextStyle(
                  color: widget.isDarkMode
                      ? AppTheme.darkSecondaryTextColor
                      : AppTheme.secondaryTextColor,
                  fontSize: 14.sp,
                  fontFamily: 'Tajawal',
                ),
                prefixIcon: Icon(Icons.search,
                    color: widget.isDarkMode
                        ? AppTheme.darkSecondaryTextColor
                        : AppTheme.secondaryTextColor),
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

          // Communities List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCommunitiesList(allCommunities, 'all'),
                _buildCommunitiesList(allCommunities.where((c) => c['isJoined']).toList(), 'joined'),
                _buildCommunitiesList(allCommunities.where((c) => c['isPopular']).toList(), 'popular'),
                _buildCommunitiesList(allCommunities.reversed.toList(), 'new'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateCommunityDialog,
        backgroundColor: AppTheme.primaryBrandColor,
        foregroundColor: Colors.white,
        label: Text(
          'إنشاء مجتمع',
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.w600,
          ),
        ),
        icon: Icon(Icons.add),
      ),
    );
  }

  Widget _buildCommunitiesList(List<Map<String, dynamic>> communities, String type) {
    // Filter communities based on search and category
    List<Map<String, dynamic>> filteredCommunities = communities.where((community) {
      bool matchesSearch = searchQuery.isEmpty ||
          community['name'].toLowerCase().contains(searchQuery.toLowerCase()) ||
          community['description'].toLowerCase().contains(searchQuery.toLowerCase());
      bool matchesCategory = selectedCategory == 'الكل' ||
          community['category'] == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    if (filteredCommunities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_off_rounded,
              size: 64.r,
              color: widget.isDarkMode
                  ? AppTheme.darkSecondaryTextColor
                  : AppTheme.secondaryTextColor,
            ),
            SizedBox(height: 16.h),
            Text(
              'لا توجد مجتمعات',
              style: TextStyle(
                color: widget.isDarkMode
                    ? AppTheme.darkPrimaryTextColor
                    : AppTheme.primaryTextColor,
                fontSize: 16.sp,
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: filteredCommunities.length,
      itemBuilder: (context, index) {
        final community = filteredCommunities[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
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
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBrandColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        community['category'],
                        style: TextStyle(
                          color: AppTheme.primaryBrandColor,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ),
                    Spacer(),
                    Expanded(
                      flex: 3,
                      child: Text(
                        community['name'],
                        style: TextStyle(
                          color: widget.isDarkMode
                              ? AppTheme.darkPrimaryTextColor
                              : AppTheme.primaryTextColor,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Tajawal',
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    CircleAvatar(
                      radius: 20.r,
                      backgroundColor: AppTheme.primaryBrandColor,
                      child: Text(
                        community['name'].substring(0, 1),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  community['description'],
                  style: TextStyle(
                    color: widget.isDarkMode
                        ? AppTheme.darkSecondaryTextColor
                        : AppTheme.secondaryTextColor,
                    fontSize: 13.sp,
                    fontFamily: 'Tajawal',
                    height: 1.4,
                  ),
                  textAlign: TextAlign.right,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: community['isJoined']
                            ? AppTheme.primaryBrandColor
                            : AppTheme.primaryBrandColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                        border: community['isJoined']
                            ? null
                            : Border.all(color: AppTheme.primaryBrandColor),
                      ),
                      child: Text(
                        community['isJoined'] ? 'منضم' : 'انضمام',
                        style: TextStyle(
                          color: community['isJoined']
                              ? Colors.white
                              : AppTheme.primaryBrandColor,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ),
                    // Stats
                    _buildStatItem(Icons.article_outlined, community['posts'].toString(), 'منشور'),
                    SizedBox(width: 16.w),
                    _buildStatItem(Icons.person_outline, community['activeMembers'].toString(), 'نشط'),
                    SizedBox(width: 16.w),
                    _buildStatItem(Icons.people_outline, community['members'], 'عضو'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(IconData icon, String count, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: widget.isDarkMode
                ? AppTheme.darkSecondaryTextColor
                : AppTheme.secondaryTextColor,
            fontSize: 11.sp,
            fontFamily: 'Tajawal',
          ),
        ),
        SizedBox(width: 2.w),
        Text(
          count,
          style: TextStyle(
            color: AppTheme.primaryBrandColor,
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'Tajawal',
          ),
        ),
        SizedBox(width: 2.w),
        Icon(
          icon,
          size: 14.r,
          color: AppTheme.primaryBrandColor,
        ),
      ],
    );
  }

  void _showFilterDialog() {
    // Implement filter dialog
  }

  void _showCreateCommunityDialog() {
    // Implement create community dialog
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
    super.dispose();
  }
}