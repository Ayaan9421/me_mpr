import 'package:flutter/material.dart';
import 'package:me_mpr/failure/diary_entry.dart';
import 'package:me_mpr/services/diary_storage_service.dart';
import 'package:me_mpr/widgets/dairy_entry_card.dart';

class DailyDairiesPage extends StatefulWidget {
  const DailyDairiesPage({super.key});

  @override
  State<DailyDairiesPage> createState() => _DailyDairiesPageState();
}

class _DailyDairiesPageState extends State<DailyDairiesPage> {
  final _storageService = DiaryStorageService();
  late Future<List<DiaryEntry>> _diariesFuture;

  @override
  void initState() {
    super.initState();
    _loadDiaries();
  }

  void _loadDiaries() {
    setState(() {
      _diariesFuture = _storageService.getDiaries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Diaries')),
      body: FutureBuilder<List<DiaryEntry>>(
        future: _diariesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'You haven\'t written any diary entries yet.',
                textAlign: TextAlign.center,
              ),
            );
          }

          final diaryEntries = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            physics: const BouncingScrollPhysics(),
            itemCount: diaryEntries.length,
            itemBuilder: (context, index) {
              return DiaryEntryCard(
                entry: diaryEntries[index],
                isReversed: index.isOdd,
              );
            },
          );
        },
      ),
    );
  }
}
