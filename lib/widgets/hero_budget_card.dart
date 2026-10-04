import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HeroBudgetCard extends StatelessWidget {
  final double totalSpent;
  final double budgetLimit;
  final VoidCallback onEditBudget;

  const HeroBudgetCard({
    super.key,
    required this.totalSpent,
    required this.budgetLimit,
    required this.onEditBudget,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final remaining = budgetLimit - totalSpent;
    final progress = budgetLimit > 0 ? (totalSpent / budgetLimit).clamp(0.0, 1.0) : 0.0;
    final percentage = (progress * 100).toInt();

    // Determine status color and label
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (totalSpent > budgetLimit && budgetLimit > 0) {
      statusColor = const Color(0xFFEF4444); // Red
      statusText = 'Over Budget';
      statusIcon = Icons.warning_rounded;
    } else if (progress >= 0.8) {
      statusColor = const Color(0xFFF59E0B); // Amber
      statusText = 'Approaching Limit';
      statusIcon = Icons.info_outline_rounded;
    } else {
      statusColor = const Color(0xFF10B981); // Emerald
      statusText = 'On Track';
      statusIcon = Icons.check_circle_outline_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F172A), // Slate 900
            Color(0xFF1E293B), // Slate 800
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with month badge and edit budget button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: onEditBudget,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.tune_rounded, color: Colors.white70, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Set Budget',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Total Spent Amount Display
          const Text(
            'Total Spent This Month',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                currencyFormatter.format(totalSpent),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '/ ${currencyFormatter.format(budgetLimit)}',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress Bar with indicator
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.white.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          const SizedBox(height: 12),

          // Remaining and Percentage Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Remaining: ${remaining >= 0 ? currencyFormatter.format(remaining) : "-${currencyFormatter.format(remaining.abs())}"}',
                style: TextStyle(
                  color: remaining >= 0 ? Colors.white70 : const Color(0xFFEF4444),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$percentage% used',
                style: TextStyle(
                  color: statusColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
