import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/validators.dart';
import '../../models/todo_model.dart';
import '../../viewmodels/todo_viewmodel.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class AddEditTodoScreen extends StatefulWidget {
  final TodoModel? todo;

  const AddEditTodoScreen({super.key, this.todo});

  @override
  State<AddEditTodoScreen> createState() => _AddEditTodoScreenState();
}

class _AddEditTodoScreenState extends State<AddEditTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _priority = AppConstants.priorityMedium;
  DateTime? _dueDate;
  bool _completed = false;

  bool get _isEditing => widget.todo != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final todo = widget.todo!;
      _titleController.text = todo.title;
      _descriptionController.text = todo.description ?? '';
      _priority = todo.priority;
      _dueDate = todo.dueDate;
      _completed = todo.completed;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final todoVM = context.read<TodoViewModel>();
    final todo = TodoModel(
      id: widget.todo?.id ?? '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      priority: _priority,
      dueDate: _dueDate,
      completed: _completed,
    );

    dynamic result;
    if (_isEditing) {
      result = await todoVM.updateTodo(widget.todo!.id, todo);
    } else {
      result = await todoVM.createTodo(todo);
    }

    if (!mounted) return;
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? 'Task updated successfully'
              : 'Task created successfully'),
          backgroundColor: AppColors.primary,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(todoVM.errorMessage ??
              (_isEditing ? 'Failed to update task' : 'Failed to create task')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Task' : 'New Task'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: 'Title',
                hint: 'What needs to be done?',
                controller: _titleController,
                validator: Validators.validateTodoTitle,
                textInputAction: TextInputAction.next,
                prefixIcon: const Icon(Icons.title),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Description',
                hint: 'Add more details (optional)',
                controller: _descriptionController,
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                prefixIcon: const Icon(Icons.description_outlined),
              ),
              const SizedBox(height: 20),
              _buildPrioritySelector(),
              const SizedBox(height: 20),
              _buildDueDatePicker(),
              if (_isEditing) ...[
                const SizedBox(height: 20),
                _buildCompletedToggle(),
              ],
              const SizedBox(height: 32),
              Consumer<TodoViewModel>(
                builder: (_, todoVM, __) => CustomButton(
                  label: _isEditing ? 'Update Task' : 'Create Task',
                  onPressed: _submit,
                  isLoading: todoVM.isLoading,
                  prefixIcon: Icon(
                    _isEditing ? Icons.save_outlined : Icons.add,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Priority', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        Row(
          children: AppConstants.priorities.map((p) {
            final isSelected = _priority == p;
            Color color;
            switch (p) {
              case 'high':
                color = AppColors.priorityHigh;
                break;
              case 'low':
                color = AppColors.priorityLow;
                break;
              default:
                color = AppColors.priorityMedium;
            }
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => setState(() => _priority = p),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? color : color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? color : color.withOpacity(0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      p[0].toUpperCase() + p.substring(1),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected ? Colors.white : color,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDueDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Due Date', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _dueDate != null
                        ? DateFormatter.toDisplay(_dueDate!)
                        : 'Select a due date (optional)',
                    style: TextStyle(
                      color: _dueDate != null
                          ? AppColors.onSurface
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                if (_dueDate != null)
                  GestureDetector(
                    onTap: () => setState(() => _dueDate = null),
                    child: const Icon(Icons.clear,
                        size: 18, color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Mark as completed',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Switch(
            value: _completed,
            onChanged: (v) => setState(() => _completed = v),
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
