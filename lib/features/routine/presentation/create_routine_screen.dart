import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_texts.dart';
import '../../../shared/theme/app_text_styles.dart';
import '../../../data/models/routine.dart';
import '../../../shared/widgets/weekday_selector.dart';
import '../../../shared/widgets/emoji_selector.dart';
import '../../../shared/widgets/custom_dropdown.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../data/routine_templates.dart';
import '../logic/routine_providers.dart';
import 'widgets/subtask_editor_tile.dart';

class CreateRoutineScreen extends ConsumerStatefulWidget {
  final CreatedRoutine? editingRoutine;

  const CreateRoutineScreen({
    super.key,
    this.editingRoutine,
  });

  @override
  ConsumerState<CreateRoutineScreen> createState() => _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends ConsumerState<CreateRoutineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _scrollController = ScrollController();
  
  String _selectedEmoji = '🌅';
  String _selectedCategory = AppTexts.wellness;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 7, minute: 0);
  List<Weekday> _selectedDays = [];
  List<Subtask> _subtasks = [];
  DateTime? _startDate;
  bool _showEmojiPicker = false;
  bool _showTemplates = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.editingRoutine != null) {
      _loadExistingRoutine();
      _showTemplates = false;
    } else {
      _selectedDays = [
        Weekday.monday,
        Weekday.tuesday,
        Weekday.wednesday,
        Weekday.thursday,
        Weekday.friday,
      ];
    }
  }

  void _loadExistingRoutine() {
    final routine = widget.editingRoutine!;
    _nameController.text = routine.name;
    _selectedEmoji = routine.emoji;
    _selectedCategory = routine.category;
    _selectedTime = TimeOfDay(
      hour: int.parse(routine.time.split(':')[0]),
      minute: int.parse(routine.time.split(':')[1].split(' ')[0]),
    );
    _selectedDays = routine.repeatDays;
    _subtasks = routine.subtasks;
    _startDate = routine.createdAt;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for routine provider errors
    ref.listen(routineProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => _handleBack(),
        ),
        title: Text(
          widget.editingRoutine != null 
              ? AppTexts.editRoutine 
              : AppTexts.createRoutine,
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          if (!_showTemplates)
            TextButton(
              onPressed: _canSave() && !_isSaving ? _saveRoutine : null,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(AppColors.primaryBlue),
                      ),
                    )
                  : Text(
                      AppTexts.save,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: _canSave() 
                            ? AppColors.primaryBlue 
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
        ],
      ),
      body: _showTemplates ? _buildTemplateSelection() : _buildRoutineForm(),
    );
  }

  Widget _buildTemplateSelection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTexts.templates,
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a template to get started quickly, or create a custom routine',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          
          ...RoutineTemplates.allTemplates.map((template) => 
            _buildTemplateCard(template)
          ),
          
          const SizedBox(height: 16),
          _buildCustomRoutineCard(),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(RoutineTemplate template) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => _selectTemplate(template),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.lightGray.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    template.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      template.description,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            template.category,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.accentGreen,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${template.subtasks.length} tasks',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomRoutineCard() {
    return GestureDetector(
      onTap: () => _startCustomRoutine(),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryBlue, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(
                  Icons.add,
                  color: AppColors.primaryBlue,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppTexts.customRoutine,
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Create your own routine from scratch',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.primaryBlue,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutineForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic Info Section
            _buildSectionHeader('Basic Information'),
            const SizedBox(height: 16),
            _buildBasicInfoCard(),
            
            const SizedBox(height: 24),
            
            // Schedule Section
            _buildSectionHeader('Schedule'),
            const SizedBox(height: 16),
            _buildScheduleCard(),
            
            const SizedBox(height: 24),
            
            // Subtasks Section
            _buildSectionHeader('Subtasks'),
            const SizedBox(height: 16),
            _buildSubtasksSection(),
            
            const SizedBox(height: 100), // Extra space for floating button
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.titleLarge.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGray.withOpacity(0.5)),
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
          // Routine Name
          Text(
            AppTexts.routineName,
            style: AppTextStyles.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return AppTexts.pleaseEnterRoutineName;
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: AppTexts.routineNameHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.lightGray),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.lightGray),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primaryBlue,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Emoji & Category Row
          Row(
            children: [
              // Emoji Selection
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppTexts.selectEmoji,
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => setState(() => _showEmojiPicker = !_showEmojiPicker),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.lightGray),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Text(
                              _selectedEmoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Tap to change',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Category Selection
              Expanded(
                child: CustomDropdown<String>(
                  label: AppTexts.category,
                  value: _selectedCategory,
                  items: RoutineTemplates.categories,
                  itemBuilder: (category) => category,
                  onChanged: (value) => setState(() => _selectedCategory = value!),
                  hint: 'Select category',
                  isRequired: true,
                ),
              ),
            ],
          ),
          
          // Emoji Picker
          if (_showEmojiPicker) ...[
            const SizedBox(height: 16),
            EmojiSelector(
              selectedEmoji: _selectedEmoji,
              onEmojiSelected: (emoji) {
                setState(() {
                  _selectedEmoji = emoji;
                  _showEmojiPicker = false;
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScheduleCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGray.withOpacity(0.5)),
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
          // Time Selection
          Text(
            AppTexts.time,
            style: AppTextStyles.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _selectTime,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.lightGray),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    color: AppColors.primaryBlue,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _selectedTime.format(context),
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Repeat Days
          Text(
            AppTexts.repeatDays,
            style: AppTextStyles.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppTexts.selectDays,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          WeekdaySelector(
            selectedDays: _selectedDays,
            onChanged: (days) => setState(() => _selectedDays = days),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_subtasks.isEmpty) 
          _buildEmptySubtasksCard()
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            onReorder: _reorderSubtasks,
            itemCount: _subtasks.length,
            itemBuilder: (context, index) {
              final subtask = _subtasks[index];
              return SubtaskEditorTile(
                key: ValueKey(subtask.id),
                subtask: subtask,
                onChanged: (updatedSubtask) => _updateSubtask(index, updatedSubtask),
                onDelete: () => _deleteSubtask(index),
              );
            },
          ),
        
        const SizedBox(height: 16),
        
        // Add Subtask Button
        GestureDetector(
          onTap: _addSubtask,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryBlue,
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(width: 8),
                Text(
                  AppTexts.addSubtask,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptySubtasksCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGray.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.lightGray.withOpacity(0.3),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.checklist,
              size: 40,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No subtasks yet',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppTexts.routineCreationTip,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _selectTemplate(RoutineTemplate template) {
    setState(() {
      _nameController.text = template.name;
      _selectedEmoji = template.emoji;
      _selectedCategory = template.category;
      _selectedTime = TimeOfDay(
        hour: template.suggestedTime.hour,
        minute: template.suggestedTime.minute,
      );
      _selectedDays = template.defaultDays;
      _subtasks = template.subtasks.asMap().entries.map((entry) => 
        Subtask(
          id: 'subtask_${entry.key}',
          name: entry.value.name,
          durationMinutes: entry.value.durationMinutes,
          requiresPhotoProof: entry.value.requiresPhotoProof,
          order: entry.key,
        )
      ).toList();
      _showTemplates = false;
    });
  }

  void _startCustomRoutine() {
    setState(() {
      _showTemplates = false;
    });
  }

  void _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  void _addSubtask() {
    setState(() {
      _subtasks.add(
        Subtask(
          id: 'subtask_${DateTime.now().millisecondsSinceEpoch}',
          name: '',
          durationMinutes: 10,
          requiresPhotoProof: false,
          order: _subtasks.length,
        ),
      );
    });
  }

  void _updateSubtask(int index, Subtask updatedSubtask) {
    setState(() {
      _subtasks[index] = updatedSubtask;
    });
  }

  void _deleteSubtask(int index) {
    setState(() {
      _subtasks.removeAt(index);
      // Update order for remaining subtasks
      for (int i = 0; i < _subtasks.length; i++) {
        _subtasks[i] = _subtasks[i].copyWith(order: i);
      }
    });
  }

  void _reorderSubtasks(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final subtask = _subtasks.removeAt(oldIndex);
      _subtasks.insert(newIndex, subtask);
      
      // Update order for all subtasks
      for (int i = 0; i < _subtasks.length; i++) {
        _subtasks[i] = _subtasks[i].copyWith(order: i);
      }
    });
  }

  Future<void> _saveRoutine() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      if (widget.editingRoutine != null) {
        // Update existing routine
        await ref.read(routineProvider.notifier).updateRoutine(
          routineId: widget.editingRoutine!.id,
          name: _nameController.text.trim(),
          emoji: _selectedEmoji,
          category: _selectedCategory,
          time: _selectedTime,
          repeatDays: _selectedDays,
          subtasks: _subtasks,
        );
        _showSuccessSnackBar('Routine updated successfully!');
      } else {
        // Create new routine
        await ref.read(routineProvider.notifier).saveRoutine(
          name: _nameController.text.trim(),
          emoji: _selectedEmoji,
          category: _selectedCategory,
          time: _selectedTime,
          repeatDays: _selectedDays,
          subtasks: _subtasks,
        );
        _showSuccessSnackBar('Routine created successfully!');
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      _showErrorSnackBar('Failed to save routine. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.accentGreen,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  bool _canSave() {
    return _nameController.text.trim().isNotEmpty &&
           _selectedDays.isNotEmpty &&
           _subtasks.isNotEmpty;
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $period';
  }

  void _handleBack() {
    if (_hasUnsavedChanges()) {
      _showUnsavedChangesDialog();
    } else {
      Navigator.of(context).pop();
    }
  }

  bool _hasUnsavedChanges() {
    if (widget.editingRoutine == null) {
      return _nameController.text.trim().isNotEmpty || _subtasks.isNotEmpty;
    }
    
    final original = widget.editingRoutine!;
    return _nameController.text.trim() != original.name ||
           _selectedEmoji != original.emoji ||
           _selectedCategory != original.category ||
           _formatTime(_selectedTime) != original.time ||
           !_listsEqual(_selectedDays, original.repeatDays) ||
           !_listsEqual(_subtasks, original.subtasks);
  }

  bool _listsEqual<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _showUnsavedChangesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text('You have unsaved changes. Are you sure you want to leave?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }
} 