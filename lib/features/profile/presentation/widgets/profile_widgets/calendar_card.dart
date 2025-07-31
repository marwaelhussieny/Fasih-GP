// lib/features/profile/presentation/widgets/calendar_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:grad_project/features/profile/domain/entities/user_entity.dart';
import 'package:grad_project/features/profile/domain/entities/daily_activity_entity.dart';

class CalendarCard extends StatelessWidget {
  final UserEntity user;
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Function(DateTime, DateTime) onDaySelected;

  const CalendarCard({
    Key? key,
    required this.user,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color textColor = theme.textTheme.bodyLarge!.color!;
    final Color mutedTextColor = theme.hintColor;
    final Color primaryColor = theme.primaryColor;
    final Color cardColor = theme.cardColor;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: cardColor, // Themed card background
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08), // Themed shadow color
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(theme, textColor, primaryColor),
          SizedBox(height: 20.h),
          _buildCalendar(theme, primaryColor, textColor, mutedTextColor),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, Color textColor, Color primaryColor) {
    return Row(
      children: [
        Icon(
          Icons.calendar_month_outlined,
          color: primaryColor, // Themed icon color
          size: 24.r,
        ),
        SizedBox(width: 8.w),
        Text(
          'التقويم والنشاط اليومي', // Calendar and Daily Activity
          style: theme.textTheme.titleMedium?.copyWith( // Themed text style
            fontFamily: 'Tajawal',
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: textColor, // Themed text color
          ),
        ),
      ],
    );
  }

  Widget _buildCalendar(ThemeData theme, Color primaryColor, Color textColor, Color mutedTextColor) {
    return TableCalendar<String>(
      locale: 'ar_EG',
      firstDay: DateTime.utc(2023, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: focusedDay,
      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
      onDaySelected: onDaySelected,
      calendarFormat: CalendarFormat.month,
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        // FIX: Ensure titleTextStyle is non-nullable
        titleTextStyle: theme.textTheme.titleMedium?.copyWith(
          fontFamily: 'Tajawal',
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          color: textColor,
        ) ?? const TextStyle(), // Provide a default TextStyle if null
        leftChevronIcon: Icon(
          Icons.chevron_left,
          color: primaryColor, // Themed chevron color
          size: 28.r,
        ),
        rightChevronIcon: Icon(
          Icons.chevron_right,
          color: primaryColor, // Themed chevron color
          size: 28.r,
        ),
      ),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: primaryColor.withOpacity(0.3), // Themed today decoration
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          // Themed selected decoration with gradient
          gradient: LinearGradient(
            colors: [primaryColor, primaryColor.darker(0.1)], // Use primary and a slightly darker shade
          ),
          shape: BoxShape.circle,
        ),
        // FIX: Ensure text styles are non-nullable
        defaultTextStyle: theme.textTheme.bodyMedium?.copyWith(
          fontFamily: 'Tajawal',
          color: textColor,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ) ?? const TextStyle(),
        todayTextStyle: theme.textTheme.bodyMedium?.copyWith(
          fontFamily: 'Tajawal',
          color: primaryColor,
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ) ?? const TextStyle(),
        selectedTextStyle: theme.textTheme.bodyMedium?.copyWith(
          fontFamily: 'Tajawal',
          color: theme.colorScheme.onPrimary,
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ) ?? const TextStyle(),
        weekendTextStyle: theme.textTheme.bodyMedium?.copyWith(
          fontFamily: 'Tajawal',
          color: Colors.red.shade400,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ) ?? const TextStyle(),
        outsideTextStyle: theme.textTheme.bodySmall?.copyWith(
          fontFamily: 'Tajawal',
          color: mutedTextColor.withOpacity(0.5),
          fontSize: 14.sp,
        ) ?? const TextStyle(),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        // FIX: Ensure text styles are non-nullable
        weekdayStyle: theme.textTheme.bodyMedium?.copyWith(
          fontFamily: 'Tajawal',
          fontWeight: FontWeight.w600,
          color: textColor,
          fontSize: 14.sp,
        ) ?? const TextStyle(),
        weekendStyle: theme.textTheme.bodyMedium?.copyWith(
          fontFamily: 'Tajawal',
          fontWeight: FontWeight.w600,
          color: Colors.red.shade400,
          fontSize: 14.sp,
        ) ?? const TextStyle(),
      ),
      calendarBuilders: CalendarBuilders<String>(
        markerBuilder: (context, date, events) {
          // FIX: Iterate through the List<DailyActivityEntity>
          final DailyActivityEntity? activityForDay = user.dailyActivities.firstWhereOrNull(
                (activity) => isSameDay(activity.date, date),
          );

          if (activityForDay != null && activityForDay.completedLessons > 0) {
            return Positioned(
              bottom: 4,
              child: Container(
                width: 6.w,
                height: 6.h,
                decoration: BoxDecoration(
                  // Themed marker decoration with gradient
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.darker(0.1)],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }
          return null;
        },
      ),
    );
  }
}

// Extension to make color darker (if not already in your AppTheme)
extension ColorExtension on Color {
  Color darker([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}

// Helper extension for List to find firstWhereOrNull (if not already available via collection package)
extension ListExtension<T> on List<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}
