// lib/features/profile/presentation/widgets/weekly_lessons_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:grad_project/features/profile/presentation/providers/activity_provider.dart';

class WeeklyLessonsCard extends StatelessWidget {
  const WeeklyLessonsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 20.h),
          _buildChart(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.trending_up_outlined,
          color: const Color(0xFFE67E22),
          size: 24.r,
        ),
        SizedBox(width: 8.w),
        Text(
          'الدروس المكتملة',
          style: TextStyle(
            fontFamily: 'Tajawal',
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildChart() {
    return Consumer<ActivityProvider>(
      builder: (context, activityProvider, child) {
        if (activityProvider.isLoadingWeekly) {
          return SizedBox(
            height: 200.h,
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFE67E22),
              ),
            ),
          );
        }

        if (activityProvider.error != null) {
          return SizedBox(
            height: 200.h,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48.r,
                    color: Colors.red.shade400,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'خطأ في تحميل البيانات',
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 14.sp,
                      color: Colors.red.shade600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final List<double> weeklyLessons = activityProvider.weeklyLessons;

        return SizedBox(
          height: 200.h,
          child: weeklyLessons.isEmpty
              ? _buildEmptyState()
              : _buildBarChart(weeklyLessons),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 48.r,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 8.h),
          Text(
            'لا توجد بيانات لهذا الأسبوع',
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 14.sp,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<double> weeklyLessons) {
    return BarChart(
      BarChartData(
        barGroups: _getBarGroups(weeklyLessons),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32.h,
              getTitlesWidget: (value, meta) => _getWeekDayTitle(value, meta),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40.w,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontFamily: 'Tajawal',
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade200,
              strokeWidth: 1,
            );
          },
        ),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => const Color(0xFFE67E22),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String weekDay = _getArabicDayName(
                  DateTime.now().subtract(Duration(days: 6 - group.x)).weekday);
              return BarTooltipItem(
                '$weekDay\n${rod.toY.round()} دروس',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Tajawal',
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _getBarGroups(List<double> data) {
    List<double> chartData = List<double>.from(data);
    while (chartData.length < 7) {
      chartData.add(0.0);
    }

    return List.generate(7, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: chartData[index],
            gradient: const LinearGradient(
              colors: [Color(0xFFE67E22), Color(0xFFD35400)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: 20.w,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(6.r),
              topRight: Radius.circular(6.r),
            ),
          ),
        ],
      );
    });
  }

  Widget _getWeekDayTitle(double value, TitleMeta meta) {
    const List<String> weekDays = ['سبت', 'أحد', 'اثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة'];
    final int index = value.toInt();

    if (index >= 0 && index < weekDays.length) {
      return Padding(
        padding: EdgeInsets.only(top: 8.h),
        child: Text(
          weekDays[index],
          style: TextStyle(
            fontSize: 12.sp,
            fontFamily: 'Tajawal',
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  String _getArabicDayName(int weekday) {
    switch (weekday) {
      case DateTime.saturday: return 'السبت';
      case DateTime.sunday: return 'الأحد';
      case DateTime.monday: return 'الاثنين';
      case DateTime.tuesday: return 'الثلاثاء';
      case DateTime.wednesday: return 'الأربعاء';
      case DateTime.thursday: return 'الخميس';
      case DateTime.friday: return 'الجمعة';
      default: return '';
    }
  }
}