import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../models/category.dart';
import '../providers/expense_provider.dart';
import 'add_category_dialog.dart';

class AddExpenseModal extends StatefulWidget {
  final Expense? initialExpense;
  final Function(Expense expense) onSave;
  final VoidCallback? onDelete;

  const AddExpenseModal({
    super.key,
    this.initialExpense,
    required this.onSave,
    this.onDelete,
  });

  static Future<void> show(
    BuildContext context, {
    Expense? initialExpense,
    required Function(Expense expense) onSave,
    VoidCallback? onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddExpenseModal(
        initialExpense: initialExpense,
        onSave: onSave,
        onDelete: onDelete,
      ),
    );
  }

  @override
  State<AddExpenseModal> createState() => _AddExpenseModalState();
}

class _AddExpenseModalState extends State<AddExpenseModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  late DateTime _selectedDate;
  late String _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialExpense?.title ?? '');
    _amountController = TextEditingController(
      text: widget.initialExpense != null ? widget.initialExpense!.amount.toStringAsFixed(2) : '',
    );
    _notesController = TextEditingController(text: widget.initialExpense?.notes ?? '');
    _selectedDate = widget.initialExpense?.date ?? DateTime.now();
    _selectedCategoryId = widget.initialExpense?.categoryId ?? ExpenseCategory.defaultCategories.first.id;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount greater than 0')),
      );
      return;
    }

    final expense = Expense(
      id: widget.initialExpense?.id,
      title: _titleController.text.trim(),
      amount: amount,
      categoryId: _selectedCategoryId,
      date: _selectedDate,
      notes: _notesController.text.trim(),
    );

    widget.onSave(expense);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialExpense != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 12,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sheet Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Expense' : 'Add New Expense',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      if (isEditing && widget.onDelete != null)
                        IconButton(
                          tooltip: 'Delete Expense',
                          icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
                          onPressed: () async {
                            final nav = Navigator.of(context);
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                title: const Text('Delete Expense?'),
                                content: const Text('Are you sure you want to delete this record?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFEF4444),
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () => Navigator.of(ctx).pop(true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              widget.onDelete?.call();
                              nav.pop();
                            }
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Large Amount Input
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    const Text(
                      '\$ ',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          hintText: '0.00',
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter amount';
                          }
                          if (double.tryParse(value.trim()) == null) {
                            return 'Enter a valid number';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Title / Merchant Input
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title / Description',
                  hintText: 'e.g. Grocery store, Netflix, Uber',
                  prefixIcon: const Icon(Icons.edit_note_rounded),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Category',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      AddCategoryDialog.show(
                        context,
                        onSave: (newCat) {
                          context.read<ExpenseProvider>().addCategory(newCat);
                          setState(() => _selectedCategoryId = newCat.id);
                        },
                      );
                    },
                    icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                    label: const Text('New Category', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Builder(
                builder: (context) {
                  final categories = context.watch<ExpenseProvider>().categories;
                  return SizedBox(
                    height: 48,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final isSelected = cat.id == _selectedCategoryId;
                        return ChoiceChip(
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedCategoryId = cat.id);
                          },
                          avatar: Icon(
                            cat.icon,
                            size: 16,
                            color: isSelected ? Colors.white : cat.color,
                          ),
                          label: Text(cat.name),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.white : null,
                          ),
                          selectedColor: const Color(0xFF10B981),
                          backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Date Picker Tile
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded, size: 20, color: Color(0xFF10B981)),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_drop_down_rounded),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Notes Input (Optional)
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Add extra details...',
                  prefixIcon: const Icon(Icons.notes_rounded),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    isEditing ? 'Save Changes' : 'Record Expense',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
