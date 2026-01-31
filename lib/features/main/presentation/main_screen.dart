import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grad_project/features/community/presentation/screens/community_screen.dart';
import 'package:grad_project/features/grammar/presentation/widgets/enhanced_features_menu_bottom_sheet.dart';
import 'package:grad_project/features/home/presentation/screens/home_screen.dart';
import 'package:grad_project/features/library/presentation/screens/library_screen.dart';
import 'package:grad_project/features/profile/presentation/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedNavIndex = 0;

  // Only 4 screens: Home, Library, Community, Profile
  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    const LibraryScreen(),
    const CommunityMainScreen(),
    const ProfileScreen(),
  ];

  // Map nav index (with 5 items) to screen index (with 4)
  int get _actualScreenIndex {
    if (_selectedNavIndex < 2) return _selectedNavIndex;
    if (_selectedNavIndex > 2) return _selectedNavIndex - 1;
    // _selectedNavIndex == 2 (اعرِبلي icon) should never display a screen
    return 0;
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      // Show Grammar Features modal bottom sheet
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const EnhancedFeaturesMenuBottomSheet(),
      );
      return;
    }
    setState(() {
      _selectedNavIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color selectedOrange = Color(0xFFB55B0A);
    const Color unselectedGrey = Color(0xFFA8A6A7);
    const Color backgroundColor = Color(0xFFFAF8EE);
    const Color navBarBackgroundColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: _widgetOptions[_actualScreenIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBarBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          child: Directionality(
            textDirection: TextDirection.ltr, // LTR order
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: selectedOrange,
              unselectedItemColor: unselectedGrey,
              selectedLabelStyle: TextStyle(
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.w500,
                fontSize: 12.sp,
              ),
              unselectedLabelStyle: TextStyle(
                fontFamily: 'Tajawal',
                fontWeight: FontWeight.w400,
                fontSize: 10.sp,
              ),
              type: BottomNavigationBarType.fixed,
              currentIndex: _selectedNavIndex,
              onTap: _onItemTapped,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined, size: 26.r),
                  label: 'الرئيسية',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.book_outlined, size: 26.r),
                  label: 'المكتبة',
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    width: 48.r,
                    height: 48.r,
                    alignment: Alignment.center,
                    child: Image.asset(
                      _selectedNavIndex == 2
                          ? 'assets/images/arabli_icon_selected.png'
                          : 'assets/images/arabli_icon_unselected.png',
                      width: 60.r,
                      height: 60.r,
                      fit: BoxFit.contain,
                    ),
                  ),
                  label: '', // No label; text is in the PNG
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_alt_outlined, size: 26.r),
                  label: 'المجتمعات',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline, size: 26.r),
                  label: 'الحساب',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}