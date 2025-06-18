import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class DynamicDateIcon extends StatelessWidget {
  final Color? color;
  final double? size;
  final bool isActive;

  const DynamicDateIcon({
    super.key,
    this.color,
    this.size = 24,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dayNumber = now.day;
    final monthName = _getShortMonthName(now.month);
    
    final iconColor = color ?? (isActive ? AppColors.primaryBlue : AppColors.textSecondary);
    
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Calendar background
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: iconColor,
                width: 1.5,
              ),
            ),
          ),
          
          // Calendar header (month)
          Positioned(
            top: 2,
            child: Container(
              width: size! * 0.8,
              height: size! * 0.25,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(2),
                  topRight: Radius.circular(2),
                ),
              ),
              child: Center(
                child: Text(
                  monthName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size! * 0.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          
          // Day number
          Positioned(
            bottom: size! * 0.15,
            child: Text(
              dayNumber.toString(),
              style: TextStyle(
                color: iconColor,
                fontSize: size! * 0.4,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getShortMonthName(int month) {
    const monthNames = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    return monthNames[month - 1];
  }
}

class AnimatedDateIcon extends StatefulWidget {
  final Color? color;
  final double? size;
  final bool isActive;

  const AnimatedDateIcon({
    super.key,
    this.color,
    this.size = 24,
    this.isActive = false,
  });

  @override
  State<AnimatedDateIcon> createState() => _AnimatedDateIconState();
}

class _AnimatedDateIconState extends State<AnimatedDateIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late DateTime _currentDate;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Check for date changes every minute
    _startDateChecker();
  }

  void _startDateChecker() {
    Future.delayed(const Duration(minutes: 1), () {
      if (mounted) {
        final now = DateTime.now();
        if (now.day != _currentDate.day) {
          setState(() {
            _currentDate = now;
          });
          _controller.forward().then((_) => _controller.reverse());
        }
        _startDateChecker();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_controller.value * 0.1),
          child: DynamicDateIcon(
            color: widget.color,
            size: widget.size,
            isActive: widget.isActive,
          ),
        );
      },
    );
  }
} 