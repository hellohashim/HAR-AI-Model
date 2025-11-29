# Text Entries App with Firebase Realtime Database

A Flutter application that allows you to manage text entries with full CRUD operations (Create, Read, Update, Delete) synchronized with Firebase Realtime Database in real-time.

## Features

- **Create**: Add new text entries
- **Read**: View all text entries with real-time updates
- **Update**: Edit existing text entries
- **Delete**: Remove text entries with confirmation dialog
- **Real-time Sync**: Automatic synchronization with Firebase Realtime Database
- **Timestamps**: Track creation and modification dates for each entry

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── models/
│   └── text_entry.dart               # TextEntry data model
├── services/
│   └── database_service.dart         # Firebase database operations
└── screens/
    └── text_entries_screen.dart      # Main UI screen
```

## Database Structure

The Firebase Realtime Database uses the following structure:

```
work-out-app-6fcba (Project)
└── text_entries/
    └── {entryId}/
        ├── text: string
        ├── createdAt: ISO 8601 timestamp
        └── updatedAt: ISO 8601 timestamp
```

## Installation & Setup

1. **Ensure Flutter and Firebase are configured:**
   ```bash
   flutter pub get
   ```

2. **Run the app:**
   ```bash
   flutter run
   ```

## Dependencies

- `firebase_core: ^2.32.0` - Firebase core library
- `firebase_database: ^10.3.0` - Firebase Realtime Database

## Usage

### Creating an Entry
1. Type text in the input field at the top
2. Click "Add Entry" button
3. Entry will be automatically saved to Firebase

### Viewing Entries
- All entries are displayed in a scrollable list below the input field
- Newest entries appear first
- Each entry shows creation and last modified timestamps

### Editing an Entry
1. Click the three-dot menu on any entry
2. Select "Edit"
3. Modify the text in the input field
4. Click "Update Entry" button

### Deleting an Entry
1. Click the three-dot menu on any entry
2. Select "Delete"
3. Confirm the deletion in the dialog

## API Reference

### DatabaseService

**Singleton pattern** - Use `DatabaseService()` to get the instance

#### Methods:

- **`getEntries()`** - Returns `Future<List<TextEntry>>`
  - Fetches all entries from Firebase

- **`getEntriesStream()`** - Returns `Stream<List<TextEntry>>`
  - Real-time stream of all entries (recommended for UI)

- **`addEntry(String text)`** - Returns `Future<bool>`
  - Creates a new text entry

- **`updateEntry(String id, String text)`** - Returns `Future<bool>`
  - Updates an existing entry

- **`deleteEntry(String id)`** - Returns `Future<bool>`
  - Deletes a specific entry

- **`deleteAllEntries()`** - Returns `Future<bool>`
  - Clears all entries

## Real-time Synchronization

The app uses `StreamBuilder` with `getEntriesStream()` to provide real-time updates. When any user adds, updates, or deletes an entry, the changes are immediately reflected in all connected clients.

## Error Handling

- All database operations include try-catch error handling
- Errors are logged to console
- User feedback is provided via SnackBars
- Confirmation dialogs prevent accidental deletions

## Future Enhancements

- Search/filter functionality
- Sort options (by date, alphabetically)
- Archive entries instead of deleting
- Categories or tags for entries
- User authentication
- Export/import data
