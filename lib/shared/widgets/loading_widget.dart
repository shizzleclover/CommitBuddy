import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

enum LoadingType {
  threeBounce,
  wave,
  ring,
  pulse,
  fadingCircle,
  wanderingCubes,
}

class LoadingWidget extends StatelessWidget {
  final String? message;
  final LoadingType type;
  final Color? color;
  final double size;
  final bool showMessage;

  const LoadingWidget({
    super.key,
    this.message,
    this.type = LoadingType.threeBounce,
    this.color,
    this.size = 30,
    this.showMessage = true,
  });

  @override
  Widget build(BuildContext context) {
    final loadingColor = color ?? AppColors.primaryBlue;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSpinner(loadingColor),
        if (showMessage && message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildSpinner(Color color) {
    switch (type) {
      case LoadingType.threeBounce:
        return SpinKitThreeBounce(
          color: color,
          size: size,
        );
      case LoadingType.wave:
        return SpinKitWave(
          color: color,
          size: size,
        );
      case LoadingType.ring:
        return SpinKitRing(
          color: color,
          size: size,
          lineWidth: 3,
        );
      case LoadingType.pulse:
        return SpinKitPulse(
          color: color,
          size: size,
        );
      case LoadingType.fadingCircle:
        return SpinKitFadingCircle(
          color: color,
          size: size,
        );
      case LoadingType.wanderingCubes:
        return SpinKitWanderingCubes(
          color: color,
          size: size,
        );
    }
  }
}

// Overlay loading widget
class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingMessage;
  final LoadingType loadingType;
  final Color? backgroundColor;

  const LoadingOverlay({
    super.key,
    required this.child,
    this.isLoading = false,
    this.loadingMessage,
    this.loadingType = LoadingType.threeBounce,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: backgroundColor ?? Colors.black.withOpacity(0.5),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: LoadingWidget(
                  message: loadingMessage ?? 'Loading...',
                  type: loadingType,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// Centered loading screen
class LoadingScreen extends StatelessWidget {
  final String? message;
  final LoadingType type;
  final Color? backgroundColor;

  const LoadingScreen({
    super.key,
    this.message,
    this.type = LoadingType.threeBounce,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.backgroundPrimary,
      body: Center(
        child: LoadingWidget(
          message: message ?? 'Loading...',
          type: type,
        ),
      ),
    );
  }
} 