//lib/features/poetry_generation/presentation/screens/poetry_generation_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grad_project/features/home/presentation/screens/home_screen.dart' show primaryOrange, desertSand, nightBlue, starGold, lightOrange; // Import theme colors

class PoetryGenerationScreen extends StatefulWidget {
const PoetryGenerationScreen({Key? key}) : super(key: key);

@override
State<PoetryGenerationScreen> createState() => _PoetryGenerationScreenState();
}

class _PoetryGenerationScreenState extends State<PoetryGenerationScreen> {
final TextEditingController _textController = TextEditingController();
String _generatedPoetry = '';
bool _isLoading = false;

@override
void dispose() {
_textController.dispose();
super.dispose();
}

Future<void> _generatePoetry() async {
setState(() {
_isLoading = true;
_generatedPoetry = ''; // Clear previous result
});

final inputText = _textController.text.trim();
if (inputText.isEmpty) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text('الرجاء إدخال جملة لإنتاج الشعر.', style: TextStyle(fontFamily: 'Tajawal', fontSize: 14.sp))),
);
setState(() {
_isLoading = false;
});
return;
}

// TODO: Implement backend call for poetry generation
// Example: final response = await context.read<PoetryProvider>().generatePoetry(inputText);
// For now, simulate a delay and provide dummy data
await Future.delayed(const Duration(seconds: 2));

setState(() {
_generatedPoetry = 'يا أيها الليل الطويل ألا انجلي، بصبح وما الإصباح منك بأمثلِ\n'
'يا أيها السيف الذي لا ينثني، إلا على هام العدا والرؤسِ\n'
'يا أيها النجم الذي في سمائه، يضيء الدروب لكل السائرين';
_isLoading = false;
});
}

@override
Widget build(BuildContext context) {
final ThemeData theme = Theme.of(context);
final bool isDarkMode = theme.brightness == Brightness.dark;

return Scaffold(
backgroundColor: isDarkMode ? nightBlue : desertSand,
appBar: AppBar(
backgroundColor: Colors.transparent,
elevation: 0,
leading: IconButton(
icon: Icon(
Icons.arrow_back_ios_new,
color: isDarkMode ? Colors.white : primaryOrange,
size: 20.r,
),
onPressed: () => Navigator.pop(context),
),
title: Text(
'إنتاج الشعر', // Poetry Generation
style: TextStyle(
color: isDarkMode ? Colors.white : primaryOrange,
fontWeight: FontWeight.bold,
fontSize: 22.sp,
),
),
centerTitle: true,
),
body: Padding(
padding: EdgeInsets.all(20.w),
child: Column(
crossAxisAlignment: CrossAxisAlignment.stretch,
children: [
// Input Field
Container(
decoration: BoxDecoration(
color: isDarkMode ? Colors.grey.shade800 : Colors.white,
borderRadius: BorderRadius.circular(16.r),
boxShadow: [
BoxShadow(
color: (isDarkMode ? Colors.black : Colors.grey).withOpacity(0.1),
blurRadius: 10,
offset: const Offset(0, 5),
),
],
),
child: TextField(
controller: _textController,
textAlign: TextAlign.right,
style: TextStyle(
color: isDarkMode ? Colors.white : Colors.black87,
fontSize: 16.sp,
fontFamily: 'Tajawal',
),
decoration: InputDecoration(
hintText: 'اكتب جملة هنا...', // Write a sentence here...
hintStyle: TextStyle(
color: isDarkMode ? Colors.white54 : Colors.grey.shade600,
fontSize: 16.sp,
fontFamily: 'Tajawal',
),
border: InputBorder.none,
contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
),
maxLines: null, // Allow multiple lines
),
),
SizedBox(height: 20.h),

// Generate Button
ElevatedButton(
onPressed: _isLoading ? null : _generatePoetry,
style: ElevatedButton.styleFrom(
backgroundColor: primaryOrange,
foregroundColor: Colors.white,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12.r),
),
padding: EdgeInsets.symmetric(vertical: 14.h),
elevation: 5,
shadowColor: primaryOrange.withOpacity(0.3),
),
child: _isLoading
? SizedBox(
height: 20.r,
width: 20.r,
child: CircularProgressIndicator(
strokeWidth: 2,
valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
),
)
: Text(
'إنتاج', // Generate
style: TextStyle(
fontFamily: 'Tajawal',
fontSize: 18.sp,
fontWeight: FontWeight.bold,
),
),
),
SizedBox(height: 20.h),

// Result Display
Expanded(
child: _isLoading
? Center(
child: CircularProgressIndicator(color: primaryOrange),
)
: _generatedPoetry.isEmpty
? Center(
child: Text(
'الشعر الناتج سيظهر هنا.', // Generated poetry will appear here.
style: TextStyle(
color: isDarkMode ? Colors.white54 : Colors.grey.shade600,
fontSize: 16.sp,
fontFamily: 'Tajawal',
),
),
)
: Container(
padding: EdgeInsets.all(16.w),
decoration: BoxDecoration(
color: isDarkMode ? Colors.grey.shade900 : Colors.white,
borderRadius: BorderRadius.circular(12.r),
boxShadow: [
BoxShadow(
color: (isDarkMode ? Colors.black : Colors.grey).withOpacity(0.1),
blurRadius: 8,
offset: const Offset(0, 4),
),
],
border: Border.all(
color: isDarkMode ? starGold.withOpacity(0.2) : primaryOrange.withOpacity(0.2),
width: 1.w,
),
),
child: SingleChildScrollView(
child: Text(
_generatedPoetry,
textAlign: TextAlign.right,
style: TextStyle(
color: isDarkMode ? Colors.white70 : Colors.black87,
fontSize: 15.sp,
fontFamily: 'Tajawal',
height: 1.6,
),
),
),
),
),
],
),
),
);
}
