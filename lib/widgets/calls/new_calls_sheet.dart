import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:me_mpr/failure/call_recording_model.dart';
import 'package:me_mpr/utils/app_colors.dart';

class NewCallsSheet extends StatefulWidget {
  final List<CallRecording> recordings;

  const NewCallsSheet({super.key, required this.recordings});

  @override
  State<NewCallsSheet> createState() => _NewCallsSheetState();
}

class _NewCallsSheetState extends State<NewCallsSheet> {
  @override
  Widget build(BuildContext context) {
    final selectedCount = widget.recordings.where((r) => r.isSelected).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'New Call Recordings Found',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select the calls you\'d like to analyze for insights.',
            style: TextStyle(color: AppColors.secondaryText),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.recordings.length,
              itemBuilder: (context, index) {
                final recording = widget.recordings[index];
                return CheckboxListTile(
                  title: Text(
                    recording.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    DateFormat.yMMMd().add_jm().format(recording.modified),
                  ),
                  value: recording.isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      recording.isSelected = value ?? false;
                    });
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: selectedCount > 0
                  ? () {
                      final selected = widget.recordings
                          .where((r) => r.isSelected)
                          .toList();
                      Navigator.of(context).pop(selected);
                    }
                  : null,
              child: Text('Analyze $selectedCount Selected Call(s)'),
            ),
          ),
        ],
      ),
    );
  }
}
