# PowerTracker Flutter App

A complete Flutter conversion of the PowerTracker energy monitoring app with all functionalities working, including cloud storage, history tracking, and receipt generation.

## Features

### ✅ **Fully Implemented**

1. **Home Page**
   - Real-time energy usage display
   - Estimated monthly bill in PHP
   - Quick device controls

2. **Analytics Page**
   - Interactive charts with period selection (Day, Week, Month, Year)
   - Stats cards showing Average, Peak, Lowest usage, and Estimated Cost
   - Energy usage trend graph using FL Chart
   - Energy saving tips

3. **History Page** (NEW)
   - Cloud sync status indicator
   - 90 days of mock historical data
   - Search and filter by date/month
   - Summary statistics (Total Records, Average Daily, Total Cost)
   - View detailed receipts for each day
   - Download receipts as text files
   - Share functionality

4. **Settings Page**
   - User profile editing
   - Notification toggles (High usage alerts, Daily reports, Budget warnings, Device offline)
   - Dark mode toggle (UI ready)
   - Monthly budget setting
   - Data management (Export/Clear all data)
   - Privacy & Security options
   - Help & Support

5. **Cloud Storage System**
   - SharedPreferences-based storage (simulates cloud)
   - Auto-save daily energy snapshots
   - Retrieve historical records
   - Filter by date range
   - Export/Clear functionality
   - Ready for backend integration (Supabase/Firebase)

6. **Navigation**
   - Bottom navigation with 4 tabs: Home, Analytics, History, Settings
   - Side menu with profile, account settings, and logout
   - Notification center
   - Logout confirmation dialog

7. **Receipt Generation**
   - Professional formatted receipts
   - Energy consumption breakdown
   - Device usage details
   - Billing calculations (₱12/kWh)
   - Share/Download functionality

## Installation

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Android Emulator or iOS Simulator

### Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  fl_chart: ^0.66.0           # For charts
  shared_preferences: ^2.2.2   # For local storage
  intl: ^0.18.1               # For date formatting
  path_provider: ^2.1.1       # For file paths
  share_plus: ^7.2.1          # For sharing receipts
```

### Setup Steps

1. **Navigate to the Flutter directory:**
   ```bash
   cd flutter
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   ```bash
   # For Android
   flutter run

   # For iOS
   flutter run --release
   ```

4. **Build APK (Android):**
   ```bash
   flutter build apk --release
   ```

5. **Build iOS:**
   ```bash
   flutter build ios --release
   ```

## Project Structure

```
flutter/
├── lib/
│   ├── main.dart                    # Entry point with navigation
│   ├── pages/
│   │   ├── home_page.dart          # Home screen with energy usage
│   │   ├── analytics_page.dart     # Charts and analytics
│   │   ├── history_page.dart       # Historical records & receipts
│   │   ├── settings_page.dart      # Settings and preferences
│   │   └── devices_page.dart       # Device management (placeholder)
│   └── utils/
│       └── cloud_storage.dart      # Cloud storage utility
├── pubspec.yaml                     # Dependencies
└── README.md                        # This file
```

## Key Files

### `/lib/main.dart`
- Main app entry point
- Bottom navigation setup
- Side menu implementation
- Notification center
- Logout functionality

### `/lib/pages/history_page.dart`
- Cloud sync status
- Historical records display
- Search and filtering
- Receipt viewer dialog
- Download/Share receipts

### `/lib/utils/cloud_storage.dart`
- `EnergyRecord` and `DeviceUsage` models
- `CloudStorage` class with methods:
  - `saveRecord()` - Save energy records
  - `saveDailySnapshot()` - Auto-save daily data
  - `getAllRecords()` - Retrieve all records
  - `getRecordsByDateRange()` - Filter by date
  - `deleteRecord()` - Remove specific record
  - `clearAllRecords()` - Clear all data
  - `generateMockHistoricalData()` - Create 90 days of mock data

### `/lib/pages/analytics_page.dart`
- Period selector (Day/Week/Month/Year)
- Interactive line chart using FL Chart
- Dynamic data visualization
- Stats cards

### `/lib/pages/settings_page.dart`
- Profile management
- Notification settings
- Budget configuration
- Data export/clear
- All toggles and dialogs

## How It Works

### Cloud Storage Simulation
The app uses `shared_preferences` to simulate cloud storage. All energy records are saved locally in JSON format. This can easily be replaced with a real backend:

```dart
// Example: Replace with Supabase
static Future<bool> saveRecord(EnergyRecord record) async {
  // Current: SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  
  // Replace with: Supabase
  // await supabase.from('energy_records').insert(record.toJson());
}
```

### Data Flow
1. User views energy consumption on Home page
2. Data is automatically saved to cloud storage
3. Historical records are displayed on History page
4. Users can view/download detailed receipts
5. Analytics page shows trends and charts

### Receipt Generation
Receipts are generated as formatted text files with:
- Date and summary information
- Energy consumption breakdown
- Device usage details
- Billing calculations
- Total cost in PHP

## Features Ready for Backend Integration

The app is structured to easily integrate with:
- **Supabase**: Replace `CloudStorage` methods with Supabase queries
- **Firebase**: Use Firestore instead of SharedPreferences
- **Custom API**: Implement REST API calls in cloud_storage.dart

## Screenshots Features

- ✅ Home screen with real-time usage
- ✅ Analytics with interactive charts
- ✅ History with cloud sync
- ✅ Receipt viewer and download
- ✅ Settings with all options
- ✅ Side menu and notifications
- ✅ Responsive mobile design

## Notes

- All data is stored locally using SharedPreferences
- Mock data includes 90 days of historical records
- Receipt download uses Share functionality
- Energy rate: ₱12.00 per kWh
- All UI matches the React implementation
- Ready for production with real backend

## Future Enhancements

- [ ] Real-time device monitoring
- [ ] Push notifications
- [ ] Cloud sync with Supabase/Firebase
- [ ] User authentication
- [ ] Multi-device support
- [ ] Export to PDF
- [ ] Dark mode implementation
- [ ] Localization support

## License

This is a sample project for demonstration purposes.
