// --- NEW: Dialog Widget for selecting reset hour ---
import 'package:flutter/material.dart';

class SelectResetHourDialog extends StatefulWidget {
  const SelectResetHourDialog();

  @override
  State<SelectResetHourDialog> createState() => SelectResetHourDialogState();
}

class SelectResetHourDialogState extends State<SelectResetHourDialog> {
  int _selectedHour = 3; // Default to 3 AM

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Chat Reset Time'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose the hour when your daily chat history should reset (e.g., during your typical sleep time).',
          ),
          const SizedBox(height: 20),
          DropdownButton<int>(
            value: _selectedHour,
            isExpanded: true,
            items: List.generate(24, (index) {
              // Format hour for display (e.g., 03:00 AM, 15:00 PM)
              final hour = index;
              final displayHour = hour == 0
                  ? 12
                  : (hour > 12 ? hour - 12 : hour);
              final ampm = hour < 12 || hour == 24 ? 'AM' : 'PM';
              final formattedTime =
                  '${displayHour.toString().padLeft(2, '0')}:00 $ampm';
              return DropdownMenuItem<int>(
                value: index,
                child: Text(formattedTime),
              );
            }),
            onChanged: (int? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedHour = newValue;
                });
              }
            },
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          // Allow dismissing only if they explicitly choose later/cancel
          onPressed: () =>
              Navigator.of(context).pop(null), // Pass null if cancelled
          child: const Text(
            'Later (Use Default)',
          ), // Maybe not needed if non-dismissible
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(
              context,
            ).pop(_selectedHour); // Return the selected hour
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
