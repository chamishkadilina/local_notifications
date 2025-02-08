// lib/widgets/day_selector_widget.dart
import 'package:flutter/material.dart';

class DaySelectorWidget extends StatelessWidget {
  final List<bool> selectedDays;
  final Function(List<bool>) onDaysChanged;

  const DaySelectorWidget({
    super.key,
    required this.selectedDays,
    required this.onDaysChanged,
  });

  @override
  Widget build(BuildContext context) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Notification Days'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: List.generate(
            7,
            (index) => FilterChip(
              label: Text(days[index]),
              selected: selectedDays[index],
              onSelected: (bool selected) {
                final newDays = List<bool>.from(selectedDays);
                newDays[index] = selected;
                onDaysChanged(newDays);
              },
            ),
          ),
        ),
      ],
    );
  }
}
