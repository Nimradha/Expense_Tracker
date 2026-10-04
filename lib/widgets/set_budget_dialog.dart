import 'package:flutter/material.dart';

class SetBudgetDialog extends StatefulWidget {
  final double currentBudget;
  final Function(double newBudget) onSave;

  const SetBudgetDialog({
    super.key,
    required this.currentBudget,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    required double currentBudget,
    required Function(double newBudget) onSave,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => SetBudgetDialog(
        currentBudget: currentBudget,
        onSave: onSave,
      ),
    );
  }

  @override
  State<SetBudgetDialog> createState() => _SetBudgetDialogState();
}

class _SetBudgetDialogState extends State<SetBudgetDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.currentBudget > 0 ? widget.currentBudget.toStringAsFixed(0) : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final value = double.tryParse(_controller.text.trim());
    if (value != null && value > 0) {
      widget.onSave(value);
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid budget amount')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.savings_rounded, color: Color(0xFF10B981)),
          SizedBox(width: 10),
          Text('Set Monthly Budget', style: TextStyle(fontSize: 18)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter your monthly spending allowance to track your financial goals.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            decoration: InputDecoration(
              prefixText: '\$ ',
              labelText: 'Monthly Limit',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Save Budget'),
        ),
      ],
    );
  }
}
