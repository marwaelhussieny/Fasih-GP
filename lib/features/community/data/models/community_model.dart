// lib/features/community/presentation/screens/community_main_communities_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grad_project/features/community/presentation/widgets/community_card.dart';
import 'package:grad_project/features/community/presentation/widgets/community_header_stats.dart';
import 'package:grad_project/features/community/presentation/widgets/community_search_bar.dart';
import 'package:grad_project/core/theme/app_theme.dart';

class CommunityMainCommunitiesTab extends StatefulWidget {
  final bool isDarkMode;

  const CommunityMainCommunitiesTab({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  State<CommunityMainCommunitiesTab> createState() => _CommunityMainCommunitiesTabState();
}

class _CommunityMainCommunitiesTabState extends State<CommunityMainCommunitiesTab> {
  String selectedFilter = 'الكل';
  List<String> filters = ['الكل', 'منضم إليها', 'الأكثر شعبية', 'جديدة'];
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> allCommunities = [
      {
        'name': 'محبي الشعر',
        'description': 'مجتمع لمحبي الشعر العربي الأصيل والحديث، نتشارك فيه أجمل القصائد والأبيات من التراث والمعاصر',
        'members': '10.2K',
        'image': 'https://placehold.co/80x80/BE5103/FFFFFF?text=شعر',
        'category': 'أدب وشعر',
        'isJoined': true,
        'isPopular': true,
        'createdDate': DateTime.now().subtract(Duration(days: 365)),
      },
      {
        'name': 'مدرسة الإعراب',
        'description': 'تعلم قواعد النحو والإعراب مع أساتذة متخصصين في اللغة العربية',
        'members': '5.7K',
        'image': 'https://placehold.co/80x80/966837/FFFFFF?text=إعراب',
        'category': 'قواعد ونحو',
        'isJoined': false,
        'isPopular': true,
        'createdDate': DateTime.now().subtract(Duration(days: 200)),
      },
      {
        'name': 'قصائد على السطور',
        'description': 'ملتقى الشعراء والكتاب لمشاركة الإبداعات الشعرية والنثرية',
        'members': '3.1K',
        'image': 'https://placehold.co/80x80/F06400/FFFFFF?text=قصائد',
        'category': 'إبداع أدبي',
        'isJoined': true,
        'isPopular': false,
        'createdDate': DateTime.now().subtract(Duration(days: 150)),
      },
      {
        'name': 'نادي البلاغة',
        'description': 'دراسة علوم البلاغة والبيان والمعاني في النصوص الأدبية',
        'members': '4.2K',
        'image': 'https://placehold.co/80x80/4A5660/FFFFFF?text=بلاغة',
        'category': 'علوم البلاغة',
        'isJoined': false,
        'isPopular': true,
        'createdDate': DateTime.now().subtract(Duration(days: 300)),
      },
    ];

    List<Map<String, dynamic>> filteredCommunities = allCommunities.where((community) {
      bool matchesSearch = searchQuery.isEmpty ||
          community['name'].toLowerCase().contains(searchQuery.toLowerCase()) ||
          community['description'].toLowerCase().contains(searchQuery.toLowerCase());

      if (!matchesSearch) return false;

      switch (selectedFilter) {
        case 'منضم إليها':
          return community['isJoined'] == true;
        case 'الأكثر شعبية':
          return community['isPopular'] == true;
        case 'جديدة':
          DateTime createdDate = community['createdDate'];
          return DateTime.now().difference(createdDate).inDays <= 60;
        default:
          return true;
      }
    }).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Stats - matching the design
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard(Icons.people_outline, '226', 'عضو'),
                Container(
                  width: 1,
                  height: 30.h,
                  color: widget.isDarkMode
                      ? AppTheme.darkSecondaryTextColor.withOpacity(0.3)
                      : AppTheme.secondaryTextColor.withOpacity(0.3),
                ),
                _buildStatCard(Icons.local_fire_department_outlined, '3', 'نشط'),
                Container(
                  width: 1,
                  height: 30.h,
                  color: widget.isDarkMode
                      ? AppTheme.darkSecondaryTextColor.withOpacity(0.3)
                      : AppTheme.secondaryTextColor.withOpacity(0.3),
                ),
                _buildStatCard(Icons.flash_on_outlined, '2,542', 'مشاركة'),
                Container(
                  width: 1,
                  height: 30.h,
                  color: widget.isDarkMode
                      ? AppTheme.darkSecondaryTextColor.withOpacity(0.3)
                      : AppTheme.secondaryTextColor.withOpacity(0.3),
                ),
                _buildStatCard(Icons.bookmark_outline, '1', 'مفضل'),
              ],
            ),
          ),

          // Search Bar
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
                prefixIcon: Icon(
                  Icons.search,
                  color: widget.isDarkMode
                      ? AppTheme.darkSecondaryTextColor
                      : AppTheme.secondaryTextColor,
                ),
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

          // Create New Community Button
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: ElevatedButton(
              onPressed: _showCreateCommunityDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBrandColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 20.r),
                  SizedBox(width: 8.w),
                  Text(
                    'إنشاء مجتمع جديد',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Communities Section Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    // Navigate to all communities screen
                    Navigator.pushNamed(context, '/all_communities');
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
                Text(
                  'أشهر المجتمعات',
                  style: TextStyle(
                    color: widget.isDarkMode
                        ? AppTheme.darkPrimaryTextColor
                        : AppTheme.primaryTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
          ),

          // Communities List
          if (filteredCommunities.isEmpty)
            _buildEmptyState()
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredCommunities.length,
              itemBuilder: (context, index) {
                final community = filteredCommunities[index];
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
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
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    leading: CircleAvatar(
                      radius: 24.r,
                      backgroundColor: AppTheme.primaryBrandColor,
                      child: Text(
                        community['name'].substring(0, 1),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ),
                    title: Text(
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
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(height: 4.h),
                        Text(
                          community['description'],
                          style: TextStyle(
                            color: widget.isDarkMode
                                ? AppTheme.darkSecondaryTextColor
                                : AppTheme.secondaryTextColor,
                            fontSize: 13.sp,
                            fontFamily: 'Tajawal',
                          ),
                          textAlign: TextAlign.right,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: community['isJoined']
                                    ? AppTheme.primaryBrandColor
                                    : AppTheme.primaryBrandColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Text(
                                community['isJoined'] ? 'منضم' : 'انضمام',
                                style: TextStyle(
                                  color: community['isJoined']
                                      ? Colors.white
                                      : AppTheme.primaryBrandColor,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  'عضو',
                                  style: TextStyle(
                                    color: widget.isDarkMode
                                        ? AppTheme.darkSecondaryTextColor
                                        : AppTheme.secondaryTextColor,
                                    fontSize: 12.sp,
                                    fontFamily: 'Tajawal',
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  community['members'],
                                  style: TextStyle(
                                    color: AppTheme.primaryBrandColor,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Tajawal',
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Icon(
                                  Icons.people_outline,
                                  size: 16.r,
                                  color: AppTheme.primaryBrandColor,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      // Navigate to community details
                    },
                  ),
                );
              },
            ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String count, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: AppTheme.primaryBrandColor,
            size: 20.r,
          ),
          SizedBox(height: 4.h),
          Text(
            count,
            style: TextStyle(
              color: widget.isDarkMode
                  ? AppTheme.darkPrimaryTextColor
                  : AppTheme.primaryTextColor,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'Tajawal',
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: widget.isDarkMode
                  ? AppTheme.darkSecondaryTextColor
                  : AppTheme.secondaryTextColor,
              fontSize: 12.sp,
              fontFamily: 'Tajawal',
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
          Icon(
            searchQuery.isNotEmpty
                ? Icons.search_off_rounded
                : Icons.group_off_rounded,
            size: 64.r,
            color: widget.isDarkMode
                ? AppTheme.darkSecondaryTextColor
                : AppTheme.secondaryTextColor,
          ),
          SizedBox(height: 16.h),
          Text(
            searchQuery.isNotEmpty
                ? 'لم نجد مجتمعات تطابق بحثك'
                : 'لا توجد مجتمعات متاحة',
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
            searchQuery.isNotEmpty
                ? 'جرب البحث بكلمات مختلفة'
                : 'تحقق مرة أخرى لاحقاً',
            style: TextStyle(
              color: widget.isDarkMode
                  ? AppTheme.darkSecondaryTextColor
                  : AppTheme.secondaryTextColor,
              fontSize: 14.sp,
              fontFamily: 'Tajawal',
            ),
            textAlign: TextAlign.center,
          ),
          if (searchQuery.isNotEmpty) ...[
            SizedBox(height: 16.h),
            TextButton(
              onPressed: () {
                setState(() {
                  searchQuery = '';
                  searchController.clear();
                });
              },
              child: Text(
                'مسح البحث',
                style: TextStyle(
                  color: AppTheme.primaryBrandColor,
                  fontSize: 14.sp,
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showCreateCommunityDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: widget.isDarkMode
              ? AppTheme.darkCardColor
              : AppTheme.cardBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            'إنشاء مجتمع جديد',
            style: TextStyle(
              color: widget.isDarkMode
                  ? AppTheme.darkPrimaryTextColor
                  : AppTheme.primaryTextColor,
              fontSize: 18.sp,
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
          content: Text(
            'هذه الميزة ستكون متاحة قريباً. ستتمكن من إنشاء مجتمعك الخاص ودعوة الأصدقاء للانضمام.',
            style: TextStyle(
              color: widget.isDarkMode
                  ? AppTheme.darkSecondaryTextColor
                  : AppTheme.secondaryTextColor,
              fontSize: 14.sp,
              fontFamily: 'Tajawal',
            ),
            textAlign: TextAlign.right,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'حسناً',
                style: TextStyle(
                  color: AppTheme.primaryBrandColor,
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

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}