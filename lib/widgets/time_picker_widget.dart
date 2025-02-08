// lib/widgets/time_picker_widget.dart
import 'package:flutter/material.dart';

class TimePickerWidget extends StatelessWidget {
  final TimeOfDay selectedTime;
  final Function(TimeOfDay) onTimeChanged;

  const TimePickerWidget({
    super.key,
    required this.selectedTime,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Notification Time'),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () async {
            final TimeOfDay? time = await showTimePicker(
              context: context,
              initialTime: selectedTime,
            );
            if (time != null) {
              onTimeChanged(time);
            }
          },
          child: Text(selectedTime.format(context)),
        ),
      ],
    );
  }
}
