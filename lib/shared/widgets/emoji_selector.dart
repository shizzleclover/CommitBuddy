import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class EmojiSelector extends StatelessWidget {
  final String selectedEmoji;
  final Function(String) onEmojiSelected;

  const EmojiSelector({
    super.key,
    required this.selectedEmoji,
    required this.onEmojiSelected,
  });

  static const List<String> _emojis = [
    '🌅', '💪', '🧘', '📚', '✨', '🎯', '🏃', '💤',
    '🧠', '🎵', '🎨', '🍎', '💧', '🌱', '🔥', '⚡',
    '🏆', '🎪', '🌟', '🚀', '💎', '🎭', '🎲', '🎸',
    '🏋️', '🤸', '🧘‍♀️', '🏊', '🚴', '🧗', '⛹️', '🤾',
    '📖', '✍️', '🎓', '🔬', '🎯', '📊', '💻', '🎨',
    '🧘‍♂️', '🌸', '🍃', '🌺', '🌻', '🌈', '☀️', '🌙',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _emojis.length,
        itemBuilder: (context, index) {
          final emoji = _emojis[index];
          final isSelected = emoji == selectedEmoji;
          
          return GestureDetector(
            onTap: () => onEmojiSelected(emoji),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppColors.primaryBlue.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: isSelected
                    ? Border.all(color: AppColors.primaryBlue, width: 2)
                    : null,
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
} 