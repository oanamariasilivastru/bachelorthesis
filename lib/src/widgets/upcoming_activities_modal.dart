import 'package:flutter/material.dart';
import 'package:app/src/models/activity.dart';

class UpcomingActivitiesModal extends StatelessWidget {
  final Map<DateTime, List<Activity>> activities;
  final ScrollController scrollController;

  const UpcomingActivitiesModal({
    Key? key,
    required this.activities,
    required this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final cutoff = DateTime(today.year, today.month, today.day);
    // doar zilele de azi sau după
    final upcomingDates = activities.keys
        .where((d) => !d.isBefore(cutoff))
        .toList()
      ..sort();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Upcoming Activities",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const Divider(thickness: 1),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: upcomingDates.length,
              itemBuilder: (context, index) {
                final date = upcomingDates[index];
                final activitiesForDate = activities[date]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Data
                    Text(
                      "${date.year}-"
                      "${date.month.toString().padLeft(2, '0')}-"
                      "${date.day.toString().padLeft(2, '0')}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Lista de activități cu checkbox
                    ...activitiesForDate.map((activity) {
                      return StatefulBuilder(
                        builder: (context, setStateItem) {
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              Icons.circle,
                              color: activity.color,
                              size: 12,
                            ),
                            title: Text(activity.title),
                            trailing: Checkbox(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              side: const BorderSide(
                                width: 2,
                                color: Colors.deepPurple,
                              ),
                              fillColor: MaterialStateProperty.all(
                                  Colors.deepPurple),
                              value: activity.isDone,
                              onChanged: (value) {
                                setStateItem(() {
                                  activity.isDone = value ?? false;
                                });
                              },
                            ),
                          );
                        },
                      );
                    }).toList(),
                    const Divider(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
