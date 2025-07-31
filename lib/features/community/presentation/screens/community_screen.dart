// lib/features/community/presentation/screens/community_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// Import theme colors from home_screen.dart for consistency
import 'package:grad_project/features/home/presentation/screens/home_screen.dart' show primaryOrange, lightOrange, warmAmber, softPeach, desertSand, nightBlue, darkPurple, starGold, moonSilver;
import 'package:grad_project/features/community/presentation/widgets/community_header_stats.dart'; // Import the new widget
import 'package:grad_project/features/community/presentation/widgets/post_card.dart'; // Import the PostCard widget

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  bool _isDarkMode = false; // State to manage dark mode

  @override
  Widget build(BuildContext context) {
    // Determine dark mode based on system theme or a user setting
    _isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: _isDarkMode ? nightBlue : desertSand,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'المجتمع', // Community
          style: TextStyle(
            color: _isDarkMode ? Colors.white : primaryOrange,
            fontWeight: FontWeight.bold,
            fontSize: 22.sp,
            fontFamily: 'Tajawal',
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: _isDarkMode ? Colors.white : primaryOrange,
              size: 24.r,
            ),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Community Header Stats
              CommunityHeaderStats(isDarkMode: _isDarkMode),
              SizedBox(height: 20.h),

              // Section for "Top Communities"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'المجتمعات الرائجة', // Top Communities
                    style: TextStyle(
                      color: _isDarkMode ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to all communities screen
                    },
                    child: Text(
                      'عرض الكل', // View All
                      style: TextStyle(
                        color: _isDarkMode ? lightOrange : primaryOrange,
                        fontSize: 14.sp,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              // Horizontal list of communities (mock data)
              SizedBox(
                height: 120.h, // Adjust height as needed
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5, // Mock number of communities
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(right: 15.w),
                      child: _buildCommunityCard(
                        'مجتمع ${index + 1}', // Community Name
                        '${(index + 1) * 100} أعضاء', // Members count
                        _isDarkMode,
                        index, // Pass index to vary colors
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20.h),

              // Section for "Latest Posts"
              Text(
                'أحدث المنشورات', // Latest Posts
                style: TextStyle(
                  color: _isDarkMode ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                  fontFamily: 'Tajawal',
                ),
                textAlign: TextAlign.right,
              ),
              SizedBox(height: 10.h),
              // List of posts (mock data)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), // Disable scrolling for this list
                itemCount: 3, // Mock number of posts
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 15.h),
                    child: PostCard(
                      userName: 'المستخدم ${index + 1}',
                      communityName: 'مجتمع ${index + 1}',
                      userAvatar: 'https://placehold.co/50x50/FF7F50/FFFFFF?text=U${index + 1}', // Placeholder image
                      postContent: 'هذا هو محتوى المنشور رقم ${index + 1}. إنه مثال على منشور في المجتمع.',
                      hashtags: ['#عربي', '#لغة', '#نحو'],
                      likes: 10 + index,
                      comments: 5 + index,
                      isDarkMode: _isDarkMode,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement create new post functionality
        },
        backgroundColor: primaryOrange,
        child: Icon(Icons.add, color: Colors.white, size: 30.r),
      ),
    );
  }

  Widget _buildCommunityCard(String title, String members, bool isDarkMode, int index) {
    // Define a list of colors to cycle through for community cards
    final List<Color> cardColors = [
      primaryOrange,
      lightOrange,
      warmAmber,
      starGold,
      moonSilver,
    ];
    final Color cardColor = cardColors[index % cardColors.length]; // Cycle through colors

    return Container(
      width: 150.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [darkPurple.withOpacity(0.8), nightBlue.withOpacity(0.6)]
              : [Colors.white, desertSand.withOpacity(0.3)],
        ),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: cardColor.withOpacity(0.3),
          width: 1.5.w,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? Colors.black : Colors.grey).withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group, // Community icon
            size: 40.r,
            color: cardColor,
          ),
          SizedBox(height: 10.h),
          Text(
            title,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              fontFamily: 'Tajawal',
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 5.h),
          Text(
            members,
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.grey.shade600,
              fontSize: 12.sp,
              fontFamily: 'Tajawal',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
