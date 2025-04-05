import 'package:flutter/material.dart';

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
    List<DateTime> upcomingDates = activities.keys
        .where((d) =>
            d.isAfter(DateTime(today.year, today.month, today.day)
                .subtract(const Duration(seconds: 1))))
        .toList();
    upcomingDates.sort((a, b) => a.compareTo(b));

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header cu titlu și buton de închidere
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
                final activitiesForDate = activities[date] ?? [];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
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
                              fillColor: MaterialStateProperty.resolveWith(
                                  (states) => Colors.deepPurple),
                              value: activity.isDone,
                              onChanged: (bool? value) {
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

// Dacă modelul Activity nu este definit în acest fișier, adaugă-l aici:
class Activity {
  final String title;
  final Color color;
  bool isDone;
  Activity({required this.title, required this.color, this.isDone = false});
}
