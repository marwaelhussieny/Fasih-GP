// lib/features/community/presentation/screens/community_main_communities_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grad_project/features/community/presentation/widgets/community_card.dart';
import 'package:grad_project/features/home/presentation/screens/home_screen.dart' show primaryOrange, desertSand, nightBlue, starGold, lightOrange, darkPurple, warmAmber, softPeach;

class CommunityMainCommunitiesTab extends StatelessWidget {
  final bool isDarkMode;

  const CommunityMainCommunitiesTab({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy data for communities
    final List<Map<String, dynamic>> communities = [
      {
        'name': 'محبي الشعر',
        'description': 'جروب محبي الشعر هو مساحة يجتمع فيها عشاق الكلمة والوزن والجمال، لتبادل أجمل الأبيات ومنظومات الشعر القديم والحديث.',
        'members': '10K',
        'image': 'https://placehold.co/100x100/A0522D/FFFFFF?text=شعر', // Placeholder for community image
      },
      {
        'name': 'مدرسة الإعراب',
        'description': 'مدرسة الإعراب هي ملتقى عشاق الدكتور أحمد خالد توفيق، ومن تربوا على كلماته ووجدوا أنفسهم بين سطوره.',
        'members': '5K',
        'image': 'https://placehold.co/100x100/4682B4/FFFFFF?text=إعراب', // Placeholder for community image
      },
      {
        'name': 'قصائد على السطور',
        'description': 'قصائد على السطور هو ملتقى عشاق الشعر حيث تمتزج الأحاسيس بالحروف وتسطر المشاعر في أبيات تكتب وتقرأ معاً.',
        'members': '923',
        'image': 'https://placehold.co/100x100/8A2BE2/FFFFFF?text=قصائد', // Placeholder for community image
      },
      {
        'name': 'نادي البلاغة',
        'description': 'مجتمع لمناقشة فنون البلاغة العربية وأسرارها وجمالياتها.',
        'members': '3.2K',
        'image': 'https://placehold.co/100x100/DAA520/FFFFFF?text=بلاغة', // Placeholder for community image
      },
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Create New Community Button
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
                  // TODO: Navigate to create new community screen
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
                          opacity: 0.1, // Subtle opacity for background text
                          child: Text(
                            'إنشاء', // Create
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
                          'إنشاء مجتمع جديد', // Create New Community
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

            // List of communities
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // Disable inner scrolling
              itemCount: communities.length,
              itemBuilder: (context, index) {
                final community = communities[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 20.h),
                  child: CommunityCard(
                    name: community['name'],
                    description: community['description'],
                    members: community['members'],
                    image: community['image'],
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
