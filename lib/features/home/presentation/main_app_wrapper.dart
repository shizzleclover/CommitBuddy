import 'package:flutter/material.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import 'home_screen.dart';
import '../../buddy/presentation/buddy_screen.dart';
import '../../routine/presentation/routines_list_screen.dart';
import '../../profile/presentation/profile_screen.dart';

class MainAppWrapper extends StatefulWidget {
  const MainAppWrapper({super.key});

  @override
  State<MainAppWrapper> createState() => _MainAppWrapperState();
}

class _MainAppWrapperState extends State<MainAppWrapper> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const RoutinesListScreen(),
    const BuddyScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

// Placeholder screens removed - now using real screens 