// lib/features/community/presentation/screens/community_main_feed_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grad_project/features/community/presentation/widgets/post_card.dart';
import 'package:grad_project/features/home/presentation/screens/home_screen.dart' show primaryOrange, desertSand, nightBlue, starGold, lightOrange, darkPurple, warmAmber, softPeach;

class CommunityMainFeedTab extends StatelessWidget {
  final bool isDarkMode;

  const CommunityMainFeedTab({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy data for posts
    final List<Map<String, dynamic>> posts = [
      {
        'user_name': 'عبدالرحمن حجاج',
        'community_name': 'محبي الشعر',
        'user_avatar': 'https://placehold.co/40x40/FF5733/FFFFFF?text=AH', // Placeholder for user avatar
        'post_content': 'الخيل والليل والبيداء تعرفني، والسيف والرمح والقرطاس والقلم. أنا الشاعر الذي لا ينثني، إلا على هام العدا والرؤسِ.',
        'hashtags': ['#الشعر_العربي', '#فخر_العرب'],
        'likes': 231,
        'comments': 52,
        'is_community_post': true,
      },
      {
        'user_name': 'أحمد أبوزيد',
        'community_name': 'مدرسة الإعراب',
        'user_avatar': 'https://placehold.co/40x40/33FF57/FFFFFF?text=AA', // Placeholder for user avatar
        'post_content': 'لم يكن يعرف أن الكلمات يمكن أن تصبح وطناً. حتى في أثر الصمت وضحك بصوت منخفض. رحمك الله يا من كتبت عنا قبل أن نعرف أنفسنا.',
        'hashtags': ['#قواعد_العربية', '#أدب', '#البلاغة', '#أسرار_اللغة'],
        'likes': 106,
        'comments': 12,
        'is_community_post': true,
      },
      {
        'user_name': 'ليلى محمد',
        'community_name': 'دروس النحو',
        'user_avatar': 'https://placehold.co/40x40/5733FF/FFFFFF?text=LM', // Placeholder for user avatar
        'post_content': 'ما هو الفرق بين الحال والتمييز؟ أجد صعوبة في التمييز بينهما. هل من توضيح؟',
        'hashtags': ['#نحو', '#قواعد_اللغة'],
        'likes': 88,
        'comments': 30,
        'is_community_post': true,
      },
      {
        'user_name': 'فاطمة الزهراء',
        'community_name': 'عشاق البلاغة',
        'user_avatar': 'https://placehold.co/40x40/FF33E9/FFFFFF?text=FZ', // Placeholder for user avatar
        'post_content': 'أعجبني قول المتنبي: "إذا رأيت نيوب الليث بارزة فلا تظنن أن الليث يبتسم". ما رأيكم في جمال هذه الاستعارة؟',
        'hashtags': ['#بلاغة', '#المتنبي', '#جمال_اللغة'],
        'likes': 150,
        'comments': 45,
        'is_community_post': true,
      },
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Create New Post Button (similar to "Create New Community" but for posts)
            Container(
              margin: EdgeInsets.only(bottom: 20.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryOrange, primaryOrange.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: primaryOrange.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to create new post screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 18.h),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: Center(
                        child: Opacity(
                          opacity: 0.1,
                          child: Text(
                            'نشر', // Post
                            style: TextStyle(
                              fontFamily: 'Tajawal',
                              fontSize: 60.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 24.r),
                        SizedBox(width: 12.w),
                        Text(
                          'إنشاء منشور جديد', // Create New Post
                          style: TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // List of posts
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // Disable inner scrolling
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 20.h),
                  child: PostCard(
                    userName: post['user_name'],
                    communityName: post['community_name'],
                    userAvatar: post['user_avatar'],
                    postContent: post['post_content'],
                    hashtags: post['hashtags'],
                    likes: post['likes'],
                    comments: post['comments'],
                    isDarkMode: isDarkMode,
                  ),
                );
              },
            ),
            SizedBox(height: 20.h), // Add some bottom padding
          ],
        ),
      ),
    );
  }
}
