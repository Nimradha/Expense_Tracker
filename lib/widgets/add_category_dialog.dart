import 'package:flutter/material.dart';
import '../models/category.dart';

class AddCategoryDialog extends StatefulWidget {
  final Function(ExpenseCategory category) onSave;

  const AddCategoryDialog({super.key, required this.onSave});

  static Future<void> show(
    BuildContext context, {
    required Function(ExpenseCategory category) onSave,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => AddCategoryDialog(onSave: onSave),
    );
  }

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _budgetController = TextEditingController();
  IconData _selectedIcon = ExpenseCategory.availableIcons.first;
  Color _selectedColor = ExpenseCategory.availableColors.first;

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final budgetText = _budgetController.text.trim();
    final budgetLimit = budgetText.isNotEmpty ? double.tryParse(budgetText) : null;

    final categoryId = 'custom_${DateTime.now().millisecondsSinceEpoch}';

    final category = ExpenseCategory(
      id: categoryId,
      name: name,
      icon: _selectedIcon,
      color: _selectedColor,
      budgetLimit: budgetLimit,
      isCustom: true,
    );

    widget.onSave(category);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Row(
        children: [
          Icon(Icons.palette_rounded, color: Color(0xFF10B981)),
          SizedBox(width: 10),
          Text('New Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Live Preview Badge
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: _selectedColor.withOpacity(0.18),
                          shape: BoxShape.circle,
                          border: Border.all(color: _selectedColor, width: 2),
                        ),
                        child: Icon(_selectedIcon, color: _selectedColor, size: 28),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _nameController.text.trim().isEmpty ? 'Category Preview' : _nameController.text.trim(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _selectedColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Name Input
                TextFormField(
                  controller: _nameController,
                  autofocus: true,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Category Name',
                    hintText: 'e.g. Coffee, Gym, Pets',
                    prefixIcon: const Icon(Icons.label_outline_rounded),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter a category name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Monthly Budget (Optional)
                TextFormField(
                  controller: _budgetController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Monthly Budget (Optional)',
                    hintText: 'e.g. 150.00',
                    prefixText: '\$ ',
                    prefixIcon: const Icon(Icons.savings_outlined),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Select Icon Section
                const Text(
                  'Select Icon',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 110,
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: ExpenseCategory.availableIcons.length,
                    itemBuilder: (context, index) {
                      final icon = ExpenseCategory.availableIcons[index];
                      final isSelected = icon == _selectedIcon;
                      return InkWell(
                        onTap: () => setState(() => _selectedIcon = icon),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _selectedColor.withOpacity(0.2)
                                : (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? _selectedColor : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            icon,
                            size: 20,
                            color: isSelected ? _selectedColor : Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Select Color Palette
                const Text(
                  'Select Color',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: ExpenseCategory.availableColors.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final color = ExpenseCategory.availableColors[index];
                      final isSelected = color == _selectedColor;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = color),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 2.5)
                                : null,
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: color.withOpacity(0.6),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                            ],
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, size: 16, color: Colors.white)
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Create Category'),
        ),
      ],
    );
  }
}
