import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_texts.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/routine.dart';
import '../logic/routine_runner_controller.dart';

class CompletionScreen extends StatefulWidget {
  final CreatedRoutine routine;
  final List<SubtaskResult> results;
  final double completionRate;
  final int totalDuration;
  final String motivationalMessage;

  const CompletionScreen({
    super.key,
    required this.routine,
    required this.results,
    required this.completionRate,
    required this.totalDuration,
    required this.motivationalMessage,
  });

  @override
  State<CompletionScreen> createState() => _CompletionScreenState();
}

class _CompletionScreenState extends State<CompletionScreen>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  
  List<ConfettiParticle> _confettiParticles = [];

  @override
  void initState() {
    super.initState();
    
    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _initializeConfetti();
    _startAnimations();
  }

  void _initializeConfetti() {
    final random = math.Random();
    _confettiParticles = List.generate(50, (index) {
      return ConfettiParticle(
        x: random.nextDouble(),
        y: -0.1,
        color: _getRandomColor(),
        size: random.nextDouble() * 8 + 4,
        velocity: random.nextDouble() * 2 + 1,
        rotation: random.nextDouble() * 2 * math.pi,
      );
    });
  }

  Color _getRandomColor() {
    final colors = [
      AppColors.primaryBlue,
      AppColors.accentGreen,
      AppColors.accentOrange,
      AppColors.accentPurple,
    ];
    return colors[math.Random().nextInt(colors.length)];
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _confettiController.forward();
    _scaleController.forward();
    
    await Future.delayed(const Duration(milliseconds: 400));
    _slideController.forward();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      body: SafeArea(
        child: Stack(
          children: [
            // Confetti Animation
            AnimatedBuilder(
              animation: _confettiController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ConfettiPainter(
                    particles: _confettiParticles,
                    animation: _confettiController,
                  ),
                  size: Size.infinite,
                );
              },
            ),
            
            // Main Content
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  
                  // Success Icon & Title
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildSuccessHeader(),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Stats Cards
                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildStatsSection(),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Routine Results
                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildResultsSection(),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Action Buttons
                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildActionButtons(),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessHeader() {
    return Column(
      children: [
        // Success Icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.accentGreen,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.accentGreen.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.check,
            color: AppColors.white,
            size: 60,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Title
        Text(
          AppTexts.routineCompleted,
          style: AppTextStyles.headlineLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Routine Name
        Text(
          widget.routine.name,
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Motivational Message
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: AppColors.accentGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.motivationalMessage,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.accentGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    final completedTasks = widget.results.where((r) => r.completed).length;
    final totalTasks = widget.results.length;
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.check_circle,
            title: AppTexts.completed,
            value: '$completedTasks/$totalTasks',
            subtitle: AppTexts.tasks,
            color: AppColors.accentGreen,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.timer,
            title: AppTexts.duration,
            value: '${widget.totalDuration}',
            subtitle: AppTexts.minutes,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.trending_up,
            title: AppTexts.successRate,
            value: '${(widget.completionRate * 100).round()}%',
            subtitle: AppTexts.completion,
            color: AppColors.accentOrange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTexts.taskResults,
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          ...widget.results.map((result) => _buildResultTile(result)),
        ],
      ),
    );
  }

  Widget _buildResultTile(SubtaskResult result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: result.completed 
            ? AppColors.accentGreen.withOpacity(0.1)
            : AppColors.lightGray.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            result.completed ? Icons.check_circle : Icons.cancel,
            color: result.completed 
                ? AppColors.accentGreen 
                : AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.subtask.name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (result.notes != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    result.notes!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            result.formattedDuration,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (result.proofImagePath != null) ...[
            const SizedBox(width: 8),
            Icon(
              Icons.camera_alt,
              color: AppColors.accentGreen,
              size: 16,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Share Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _shareResults,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.share, size: 20),
                const SizedBox(width: 8),
                Text(
                  AppTexts.shareWithBuddy,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Back to Home Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).popUntil(
              (route) => route.isFirst,
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.lightGray),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              AppTexts.backToHome,
              style: AppTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _shareResults() {
    // TODO: Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sharing functionality coming soon!'),
        backgroundColor: AppColors.primaryBlue,
      ),
    );
  }
}

class ConfettiParticle {
  double x;
  double y;
  final Color color;
  final double size;
  final double velocity;
  final double rotation;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.velocity,
    required this.rotation,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final Animation<double> animation;

  ConfettiPainter({
    required this.particles,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    for (final particle in particles) {
      // Update particle position
      final progress = animation.value;
      final currentY = particle.y + (progress * size.height * particle.velocity);
      
      if (currentY > size.height) continue;
      
      paint.color = particle.color;
      
      final center = Offset(
        particle.x * size.width,
        currentY,
      );
      
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(particle.rotation * progress);
      
      canvas.drawCircle(
        Offset.zero,
        particle.size,
        paint,
      );
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 