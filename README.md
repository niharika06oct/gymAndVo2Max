# FitStrength VO₂

A comprehensive fitness tracking app that combines VO₂ max monitoring with strength training to help users track their fitness goals and compare their performance against population norms.

## 🎯 Features

### VO₂ Max Tracking
- **Cooper Test Integration**: Calculate VO₂ max using the Cooper 12-minute run test
- **Percentile Ranking**: Compare your VO₂ max against ACSM normative data for your age and sex
- **Fitness Level Classification**: Get categorized feedback (Superior, Excellent, Good, Fair, Poor)
- **Progress Tracking**: Monitor VO₂ max improvements over time

### Strength Training
- **Exercise Library**: Comprehensive database of exercises with muscle group targeting
- **Workout Logging**: Track sets, reps, loads, and RPE (Rate of Perceived Exertion)
- **Muscle Coverage Analysis**: Visual radar chart showing muscle group training balance
- **Volume Tracking**: Monitor training volume per muscle group

### HIIT Quality Assessment
- **HIIT Score**: Weekly compliance tracking for high-intensity interval training
- **Population Comparison**: Compare your HIIT adherence to CDC guidelines (only ~24% of adults meet both cardio + strength targets)

### Data Visualization
- **VO₂ Percentile Ring**: Circular progress indicator showing your fitness percentile
- **Muscle Radar Chart**: Visual representation of muscle group coverage
- **Progress Charts**: Track improvements over time with fl_chart integration

## 🏗️ Technical Architecture

### State Management
- **Riverpod**: Reactive state management for clean, testable code
- **Provider Pattern**: Efficient data flow and dependency injection

### Local Database
- **Hive**: Fast, lightweight NoSQL database for offline data storage
- **Code Generation**: Automatic adapter generation for type-safe data access
- **Multi-platform**: Works on iOS, Android, Web, macOS, Windows, Linux

### Dependencies
```yaml
dependencies:
  flutter_riverpod: ^2.6.1    # State management
  hive: ^2.2.3               # Local database
  hive_flutter: ^1.1.0       # Flutter integration
  fl_chart: ^1.0.0           # Data visualization

dev_dependencies:
  build_runner: ^2.4.0       # Code generation
  hive_generator: ^2.0.1     # Hive adapters
```

## 📱 Screens

### Home Dashboard
- VO₂ percentile ring with fitness level indicator
- HIIT quality score with weekly compliance bar
- Muscle coverage radar chart
- Quick action buttons for logging workouts and tests

### VO₂ Test Screen
- Cooper test distance input
- Real-time VO₂ calculation using formula: `VO₂ = (distance_m − 504.9) / 44.73`
- Percentile ranking against ACSM norms
- Fitness level classification with color coding
- Save test results to local database

### Workout Logger
- Exercise selection from comprehensive library
- Set tracking with reps, load, and RPE
- Real-time muscle coverage calculation
- Visual feedback on training volume per muscle group

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK (3.8.1 or higher)

### Installation
```bash
# Clone the repository
git clone <your-repo-url>
cd fit_strength_vo2

# Install dependencies
flutter pub get

# Generate Hive adapters
dart run build_runner build

# Run the app
flutter run
```

### Building for Production
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## 📊 Data Models

### VO₂ Record
```dart
class Vo2Record {
  DateTime date;
  double vo2;          // ml·kg⁻¹·min⁻¹
  String method;       // 'Cooper', 'Watch', etc.
}
```

### Exercise
```dart
class Exercise {
  String id;
  String name;
  List<String> primaryMuscles;
  List<String>? secondaryMuscles;
  String? category;
  String? defaultUnit;   // 'kg', 'lb', etc.
}
```

### Workout Session
```dart
class WorkoutSession {
  String id;
  DateTime start;
  DateTime end;
  List<WorkoutSet> sets;
  List<Interval> intervals;
  double? vo2Estimate;
  int? perceivedEffort;
  String? notes;
}
```

## 🧪 Testing VO₂ Max

### Cooper Test Protocol
1. Warm up for 5-10 minutes
2. Run as far as possible in exactly 12 minutes
3. Measure distance in meters
4. Enter distance in the app
5. Get instant VO₂ max calculation and percentile ranking

### Fitness Level Reference (30-39 year old men)
- **Superior** (≥ 57 ml·kg⁻¹·min⁻¹): 95th+ percentile
- **Excellent** (54-56): 90th percentile
- **Good** (45-53): 75th-89th percentile
- **Fair** (34-44): 40th-74th percentile
- **Poor** (≤ 33): Below 40th percentile

## 🎨 UI/UX Features

- **Material 3 Design**: Modern, accessible interface
- **Dark/Light Mode**: Automatic theme adaptation
- **Responsive Layout**: Works on all screen sizes
- **Intuitive Navigation**: Clear, logical user flow
- **Visual Feedback**: Color-coded progress indicators

## 🔮 Future Enhancements

- **Wearable Integration**: Apple HealthKit and Google Fit support
- **HIIT Session Logger**: Interval training with heart rate tracking
- **Progress Analytics**: Advanced charts and trend analysis
- **Social Features**: Friend leaderboards and sharing
- **AI Coaching**: Personalized workout recommendations
- **Export Features**: CSV export and Strava sync

## 📈 Performance Metrics

The app helps users track:
- **VO₂ max trends** over time
- **Muscle balance** across all major muscle groups
- **HIIT compliance** against CDC guidelines
- **Training volume** per muscle group
- **RPE trends** for intensity monitoring

## 🤝 Contributing

This is a personal project, but suggestions and feedback are welcome!

## 📄 License

This project is for personal use and educational purposes.

---

**Built with ❤️ using Flutter and Riverpod**
