import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../models/day.dart';

class DayTabs extends StatelessWidget {
  final List<Day> days;
  final int? selectedDayId;
  final ValueChanged<int> onDaySelected;

  const DayTabs({super.key, required this.days, required this.selectedDayId, required this.onDaySelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final day = days[index];
          final selected = day.id == selectedDayId;
          return GestureDetector(
            onTap: () => onDaySelected(day.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: selected ? AppColors.primary : AppColors.border),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Day ${day.dayNumber}',
                    style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  if (day.date != null)
                    Text(
                      day.date!,
                      style: TextStyle(
                        fontSize: 10,
                        color: selected ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
