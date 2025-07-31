import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  final List<Map<String, String>> onboardingData = [
    {
      'image': 'assets/onboarding/guide1.png',
      'title': 'مرحبًا بك في فصيح',
      'subtitle': 'تطبيق فصيح يساعدك على تعلم اللغة العربية بطريقة ممتعة وتفاعلية',
    },
    {
      // 'image': 'assets/onboarding/guide2.svg',
      'title': 'تعلم القواعد بسهولة',
      'subtitle': 'نوضح لك قواعد النحو والإملاء بطريقة سلسة وبسيطة',
    },
    {
      'image': 'assets/onboarding/guide2.png',
      'title': 'اختبر نفسك وتقدّم',
      'subtitle': 'تحديات واختبارات دورية تعزز مهاراتك اللغوية',
    },
    {
      'image': 'assets/onboarding/guide1.png',
      'title': 'ابدأ رحلتك الآن!',
      'subtitle': 'اكتشف تجربة تعليمية فريدة مع فصيح',
    },
  ];

  void _nextPage() {
    if (currentIndex < onboardingData.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8EE),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: onboardingData.length,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final data = onboardingData[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        SvgPicture.asset(
                          data['image']!,
                          height: 260,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          data['title']!,
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF3D3D3D),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          data['subtitle']!,
                          style: const TextStyle(
                            fontFamily: 'Tajawal',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF9B9B9B),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SmoothPageIndicator(
              controller: _controller,
              count: onboardingData.length,
              effect: const ExpandingDotsEffect(
                activeDotColor: Color(0xFFBE5103),
                dotColor: Color(0xFFC4C4C4),
                dotHeight: 10,
                dotWidth: 10,
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3D3D3D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    currentIndex == onboardingData.length - 1 ? 'ابدأ' : 'التالي',
                    style: const TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

// TODO: Add shared_preferences logic to track if onboarding is completed
}
