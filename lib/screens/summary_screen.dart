import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../widgets/set_budget_dialog.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  int _selectedChartTab = 0; // 0: Pie (Categories), 1: Bar (Weekly Trends)
  int _touchedPieIndex = -1;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final currentMonthExpenses = provider.expenses;
    final totalSpent = provider.totalSpent;
    final budgetLimit = provider.monthlyBudget;
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Group expenses by category
    final Map<String, double> categoryTotals = {};
    for (final exp in currentMonthExpenses) {
      categoryTotals[exp.categoryId] = (categoryTotals[exp.categoryId] ?? 0.0) + exp.amount;
    }

    final hasData = categoryTotals.isNotEmpty && totalSpent > 0;
    final budgetProgress = budgetLimit > 0 ? (totalSpent / budgetLimit).clamp(0.0, 1.0) : 0.0;
    final remainingBudget = budgetLimit - totalSpent;

    // Daily Average Calculation
    final now = DateTime.now();
    final daysPassed = (provider.selectedMonth.year == now.year && provider.selectedMonth.month == now.month)
        ? now.day
        : DateTime(provider.selectedMonth.year, provider.selectedMonth.month + 1, 0).day;
    final dailyAverage = daysPassed > 0 ? totalSpent / daysPassed : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Analytics', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'Change Month',
            icon: const Icon(Icons.calendar_today_rounded, size: 20),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: provider.selectedMonth,
                firstDate: DateTime(2022),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                provider.changeMonth(picked);
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= 1. BUDGET TRACKING HERO =================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Monthly Budget Status',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      InkWell(
                        onTap: () {
                          SetBudgetDialog.show(
                            context,
                            currentBudget: budgetLimit,
                            onSave: (val) => provider.setMonthlyBudget(val),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.edit_rounded, color: Colors.white70, size: 12),
                              SizedBox(width: 4),
                              Text('Edit', style: TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        currencyFormat.format(totalSpent),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Limit: ${currencyFormat.format(budgetLimit)}',
                        style: const TextStyle(color: Colors.white60, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: budgetProgress,
                      minHeight: 10,
                      backgroundColor: Colors.white.withOpacity(0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        totalSpent > budgetLimit
                            ? const Color(0xFFEF4444)
                            : (budgetProgress >= 0.8
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFF10B981)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        remainingBudget >= 0
                            ? 'Remaining: ${currencyFormat.format(remainingBudget)}'
                            : 'Over by: ${currencyFormat.format(remainingBudget.abs())}',
                        style: TextStyle(
                          color: remainingBudget >= 0 ? Colors.white70 : const Color(0xFFEF4444),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${(budgetProgress * 100).toInt()}% utilized',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ================= 2. QUICK METRICS ROW =================
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    title: 'Daily Average',
                    value: currencyFormat.format(dailyAverage),
                    icon: Icons.calendar_today_rounded,
                    color: const Color(0xFF06B6D4),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    title: 'Total Records',
                    value: '${currentMonthExpenses.length} items',
                    icon: Icons.receipt_rounded,
                    color: const Color(0xFF8B5CF6),
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ================= 3. CHART TOGGLE & VISUALIZATION =================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Spending Analytics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 0, icon: Icon(Icons.pie_chart_rounded, size: 16), label: Text('Category')),
                    ButtonSegment(value: 1, icon: Icon(Icons.bar_chart_rounded, size: 16), label: Text('Weekly')),
                  ],
                  selected: {_selectedChartTab},
                  onSelectionChanged: (val) => setState(() => _selectedChartTab = val.first),
                ),
              ],
            ),
            const SizedBox(height: 14),

            if (!hasData)
              Container(
                height: 200,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('No expense data available for this month.'),
              )
            else if (_selectedChartTab == 0)
              // PIE CHART VIEW
              _buildPieChartSection(provider, categoryTotals, totalSpent, isDark)
            else
              // BAR CHART VIEW
              _buildBarChartSection(currentMonthExpenses, isDark),

            const SizedBox(height: 24),

            // ================= 4. CATEGORY BUDGET BREAKDOWN =================
            const Text(
              'Category Budget Performance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ...categoryTotals.entries.map((entry) {
              final cat = provider.getCategory(entry.key);
              final spent = entry.value;
              final catBudget = cat.budgetLimit;
              final catProgress = catBudget != null && catBudget > 0 ? (spent / catBudget).clamp(0.0, 1.0) : (spent / totalSpent);

              Color progressColor = cat.color;
              if (catBudget != null) {
                if (spent > catBudget) {
                  progressColor = const Color(0xFFEF4444);
                } else if (spent / catBudget >= 0.8) {
                  progressColor = const Color(0xFFF59E0B);
                }
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: cat.color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(cat.icon, color: cat.color, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                cat.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                catBudget != null
                                    ? 'Budget: ${currencyFormat.format(catBudget)}'
                                    : '${((spent / totalSpent) * 100).toStringAsFixed(1)}% of total',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          currencyFormat.format(spent),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: catBudget != null && spent > catBudget
                                ? const Color(0xFFEF4444)
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: catProgress,
                        minHeight: 7,
                        backgroundColor: Colors.grey.withOpacity(0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChartSection(
    ExpenseProvider provider,
    Map<String, double> categoryTotals,
    double totalSpent,
    bool isDark,
  ) {
    final entries = categoryTotals.entries.toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 210,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        _touchedPieIndex = -1;
                        return;
                      }
                      _touchedPieIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                sectionsSpace: 3,
                centerSpaceRadius: 42,
                sections: entries.asMap().entries.map((item) {
                  final index = item.key;
                  final entry = item.value;
                  final isTouched = index == _touchedPieIndex;
                  final cat = provider.getCategory(entry.key);
                  final percentage = (entry.value / totalSpent) * 100;

                  return PieChartSectionData(
                    color: cat.color,
                    value: entry.value,
                    title: isTouched
                        ? '${cat.name}\n\$${entry.value.toStringAsFixed(0)}'
                        : '${percentage.toStringAsFixed(0)}%',
                    radius: isTouched ? 65 : 52,
                    titleStyle: TextStyle(
                      fontSize: isTouched ? 12 : 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: entries.map((entry) {
              final cat = provider.getCategory(entry.key);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(color: cat.color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    cat.name,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChartSection(List<dynamic> expenses, bool isDark) {
    // Group totals into 4 weeks of the month
    final List<double> weeklyTotals = [0.0, 0.0, 0.0, 0.0];
    for (final exp in expenses) {
      final day = exp.date.day;
      if (day <= 7) {
        weeklyTotals[0] += exp.amount;
      } else if (day <= 14) {
        weeklyTotals[1] += exp.amount;
      } else if (day <= 21) {
        weeklyTotals[2] += exp.amount;
      } else {
        weeklyTotals[3] += exp.amount;
      }
    }

    final maxVal = weeklyTotals.reduce((a, b) => a > b ? a : b);
    final maxY = maxVal > 0 ? maxVal * 1.25 : 100.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Expenditure Distribution',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => const Color(0xFF0F172A),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        'Week ${group.x + 1}\n\$${rod.toY.toStringAsFixed(2)}',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const titles = ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
                        final text = (value.toInt() >= 0 && value.toInt() < titles.length)
                            ? titles[value.toInt()]
                            : '';
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (val) => FlLine(
                    color: Colors.grey.withOpacity(0.12),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(4, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: weeklyTotals[index],
                        color: const Color(0xFF10B981),
                        width: 22,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
