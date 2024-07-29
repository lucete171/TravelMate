import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TravelCalendar extends StatefulWidget {
  const TravelCalendar({super.key});

  @override
  _TravelCalendarState createState() => _TravelCalendarState();
}

class _TravelCalendarState extends State<TravelCalendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, String> _notes = {};
  TextEditingController _noteController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _notes = (prefs.getStringList('notes') ?? []).fold({}, (map, entry) {
        final parts = entry.split('|');
        if (parts.length == 2) {
          map[DateTime.parse(parts[0])] = parts[1];
        }
        return map;
      });
    });
  }

  Future<void> _saveNotes() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final noteEntries = _notes.entries
        .map((entry) => '${entry.key.toIso8601String()}|${entry.value}')
        .toList();
    await prefs.setStringList('notes', noteEntries);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Calendar'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _noteController.text = _notes[_selectedDay] ?? '';
                    _isEditing = false;
                  });
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                calendarStyle: CalendarStyle(
                  todayDecoration: const BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: Colors.deepPurpleAccent,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                eventLoader: (day) {
                  return _notes[day] != null ? ['Note'] : [];
                },
              ),
              const SizedBox(height: 16.0),
              if (_selectedDay != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      if (_notes[_selectedDay] != null && !_isEditing)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _notes[_selectedDay]!,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isEditing = true;
                                });
                              },
                              child: const Text('수정하기'),
                            ),
                          ],
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _noteController,
                              maxLines: null,
                              decoration: const InputDecoration(
                                labelText: '메모 추가',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _notes[_selectedDay!] = _noteController.text;
                                  _isEditing = false;
                                });
                                _saveNotes();
                              },
                              child: const Text('저장'),
                            ),
                          ],
                        ),
                    ],
                  ),
                )
              else
                const Center(
                  child: Text(
                    'Select a day to view or add notes.',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
