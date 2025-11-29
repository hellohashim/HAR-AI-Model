import 'package:firebase_database/firebase_database.dart';
import 'package:work_out_app/models/text_entry.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  late DatabaseReference _entriesRef;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal() {
    _entriesRef = FirebaseDatabase.instance.ref('text_entries');
    print('DEBUG: DatabaseService initialized with ref path: ${_entriesRef.path}');
  }

  // GET: Fetch all entries
  Future<List<TextEntry>> getEntries() async {
    try {
      final snapshot = await _entriesRef.get();
      if (snapshot.exists) {
        final Map<dynamic, dynamic> data =
            snapshot.value as Map<dynamic, dynamic>;
        return data.entries
            .map((entry) => TextEntry.fromJson(
                entry.value as Map<dynamic, dynamic>, entry.key as String))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching entries: $e');
      return [];
    }
  }

  // Stream to listen for real-time updates
  Stream<List<TextEntry>> getEntriesStream() {
    print('DEBUG: getEntriesStream called');
    return _entriesRef.onValue.map((event) {
      print('DEBUG: Stream event received. Snapshot exists: ${event.snapshot.exists}');
      print('DEBUG: Snapshot value: ${event.snapshot.value}');
      
      if (event.snapshot.exists) {
        final Map<dynamic, dynamic> data =
            event.snapshot.value as Map<dynamic, dynamic>;
        final entries = data.entries
            .map((entry) => TextEntry.fromJson(
                entry.value as Map<dynamic, dynamic>, entry.key as String))
            .toList();
        print('DEBUG: Parsed ${entries.length} entries');
        return entries;
      }
      print('DEBUG: Snapshot does not exist');
      return [];
    });
  }

  // CREATE: Add a new entry
  Future<bool> addEntry(String text) async {
    try {
      print('DEBUG: Starting to add entry with text: $text');
      print('DEBUG: Database reference path: ${_entriesRef.path}');
      
      final newEntry = TextEntry(
        id: '',
        text: text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final newRef = _entriesRef.push();
      print('DEBUG: New reference path: ${newRef.path}');
      
      final data = {
        'text': newEntry.text,
        'createdAt': newEntry.createdAt.toIso8601String(),
        'updatedAt': newEntry.updatedAt.toIso8601String(),
      };
      print('DEBUG: Setting data: $data');
      
      await newRef.set(data);
      print('DEBUG: Entry added successfully');
      return true;
    } catch (e) {
      print('Error adding entry: $e');
      print('Error type: ${e.runtimeType}');
      return false;
    }
  }

  // UPDATE: Update an existing entry
  Future<bool> updateEntry(String id, String text) async {
    try {
      await _entriesRef.child(id).update({
        'text': text,
        'updatedAt': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error updating entry: $e');
      return false;
    }
  }

  // DELETE: Delete an entry
  Future<bool> deleteEntry(String id) async {
    try {
      await _entriesRef.child(id).remove();
      return true;
    } catch (e) {
      print('Error deleting entry: $e');
      return false;
    }
  }

  // DELETE ALL: Clear all entries
  Future<bool> deleteAllEntries() async {
    try {
      await _entriesRef.remove();
      return true;
    } catch (e) {
      print('Error deleting all entries: $e');
      return false;
    }
  }
}
