// lib/features/main/presentation/screens/main_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grad_project/features/community/presentation/screens/community_screen.dart';

// Import your actual screens
import 'package:grad_project/features/home/presentation/screens/home_screen.dart';
import 'package:grad_project/features/profile/presentation/screens/profile_screen.dart';
import 'package:grad_project/features/grammar/presentation/widgets/grammar_features_menu_bottom_sheet.dart';

// Import theme colors for consistency
import 'package:grad_project/features/home/presentation/screens/home_screen.dart' show primaryOrange, desertSand, nightBlue, starGold, darkPurple;

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  // List of widgets to display for each tab (excluding the middle FAB)
  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    const DummyScreen(title: 'المكتبة'),
    const CommunityScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    // Handle the middle button (index 2) separately
    if (index == 2) {
      _showGrammarFeaturesMenu();
      return;
    }

    // Adjust index for the widget list (since we removed the middle item)
    int adjustedIndex = index > 2 ? index - 1 : index;

    setState(() {
      _selectedIndex = adjustedIndex;
    });
  }

  void _showGrammarFeaturesMenu() {
    _fabAnimationController.forward().then((_) {
      _fabAnimationController.reverse();
    });

    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      builder: (context) => FeaturesMenuBottomSheet(isDarkMode: isDarkMode),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    // Use theme colors
    final Color selectedColor = isDarkMode ? starGold : primaryOrange;
    final Color unselectedColor = isDarkMode ? Colors.white54 : const Color(0xFFA8A6A7);
    final Color backgroundColor = isDarkMode ? nightBlue : desertSand;
    final Color navBarBackgroundColor = isDarkMode ? darkPurple : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBarBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1),
              blurRadius: 15,
              spreadRadius: 0,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
          child: Stack(
            children: [
              BottomNavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedItemColor: selectedColor,
                unselectedItemColor: unselectedColor,
                selectedLabelStyle: TextStyle(
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                ),
                unselectedLabelStyle: TextStyle(
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.w400,
                  fontSize: 10.sp,
                ),
                type: BottomNavigationBarType.fixed,
                currentIndex: _selectedIndex > 1 ? _selectedIndex + 1 : _selectedIndex,
                onTap: _onItemTapped,
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: _buildNavIcon(Icons.home_outlined, 0),
                    label: 'الرئيسية',
                  ),
                  BottomNavigationBarItem(
                    icon: _buildNavIcon(Icons.book_outlined, 1),
                    label: 'المكتبة',
                  ),
                  // Middle item placeholder (will be covered by FAB)
                  BottomNavigationBarItem(
                    icon: SizedBox(height: 24.r),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: _buildNavIcon(Icons.people_alt_outlined, 3),
                    label: 'المجتمعات',
                  ),
                  BottomNavigationBarItem(
                    icon: _buildNavIcon(Icons.person_outline, 4),
                    label: 'الحساب',
                  ),
                ],
              ),
              // Custom FAB positioned in the center
              Positioned(
                top: -10.h,
                left: MediaQuery.of(context).size.width / 2 - 35.w,
                child: ScaleTransition(
                  scale: _fabAnimation,
                  child: GestureDetector(
                    onTap: _showGrammarFeaturesMenu,
                    child: Container(
                      width: 70.w,
                      height: 70.w,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDarkMode
                              ? [starGold, starGold.withOpacity(0.8)]
                              : [primaryOrange, primaryOrange.withOpacity(0.8)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (isDarkMode ? starGold : primaryOrange).withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: (isDarkMode ? starGold : primaryOrange).withOpacity(0.2),
                            blurRadius: 25,
                            offset: const Offset(0, 10),
                            spreadRadius: -5,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Main icon
                          Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 28.r,
                          ),
                          // Animated pulse effect
                          TweenAnimationBuilder<double>(
                            duration: const Duration(seconds: 2),
                            tween: Tween(begin: 0.0, end: 1.0),
                            onEnd: () => setState(() {}), // Restart animation
                            builder: (context, value, child) {
                              return Container(
                                width: 70.w * (1 + value * 0.3),
                                height: 70.w * (1 + value * 0.3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: (isDarkMode ? starGold : primaryOrange)
                                        .withOpacity(0.3 * (1 - value)),
                                    width: 2.w,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, int index) {
    // Adjust the current index comparison for items after the FAB
    int currentIndex = _selectedIndex > 1 ? _selectedIndex + 1 : _selectedIndex;
    bool isSelected = currentIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.all(isSelected ? 8.w : 4.w),
      decoration: BoxDecoration(
        color: isSelected
            ? (Theme.of(context).brightness == Brightness.dark ? starGold : primaryOrange).withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(
        icon,
        size: isSelected ? 26.r : 24.r,
      ),
    );
  }
}

// Enhanced DummyScreen with better theming
class DummyScreen extends StatelessWidget {
  final String title;

  const DummyScreen({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? nightBlue : desertSand,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
            color: isDarkMode ? starGold : primaryOrange,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(20.w),
          padding: EdgeInsets.all(30.w),
          decoration: BoxDecoration(
            color: isDarkMode ? darkPurple.withOpacity(0.7) : Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: (isDarkMode ? starGold : primaryOrange).withOpacity(0.3),
              width: 1.5.w,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDarkMode ? Colors.black : Colors.grey).withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: (isDarkMode ? starGold : primaryOrange).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.build_circle_outlined,
                  size: 60.r,
                  color: isDarkMode ? starGold : primaryOrange,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'قريباً',
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? starGold : primaryOrange,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'صفحة $title قيد التطوير',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 16.sp,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'سنعمل على إتاحتها قريباً',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 14.sp,
                  color: isDarkMode ? Colors.white54 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}