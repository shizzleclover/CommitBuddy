import 'package:flutter/material.dart';

class DateUtils {
  /// Gets the current date and returns it as a DateTime object
  static DateTime getCurrentDate() {
    return DateTime.now();
  }

  /// Gets the current day number as a string
  static String getCurrentDay() {
    return DateTime.now().day.toString();
  }

  /// Gets the current month name (short form)
  static String getCurrentMonthShort() {
    const monthNames = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    return monthNames[DateTime.now().month - 1];
  }

  /// Gets the current month name (full form)
  static String getCurrentMonthFull() {
    const monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return monthNames[DateTime.now().month - 1];
  }

  /// Gets the current year as a string
  static String getCurrentYear() {
    return DateTime.now().year.toString();
  }

  /// Formats the current date as a readable string
  static String formatCurrentDate({bool includeYear = true}) {
    final now = DateTime.now();
    final month = getCurrentMonthFull();
    final day = now.day;
    final year = now.year;
    
    if (includeYear) {
      return '$month $day, $year';
    } else {
      return '$month $day';
    }
  }

  /// Gets a greeting based on the time of day
  static String getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  /// Checks if it's a weekend
  static bool isWeekend() {
    final weekday = DateTime.now().weekday;
    return weekday == DateTime.saturday || weekday == DateTime.sunday;
  }

  /// Gets the day of the week as a string
  static String getCurrentDayOfWeek() {
    const dayNames = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 
      'Friday', 'Saturday', 'Sunday'
    ];
    return dayNames[DateTime.now().weekday - 1];
  }
} 