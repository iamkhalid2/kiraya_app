# Kiraya - Rent Management Application

A comprehensive rent management application built with Flutter and Firebase, designed to help property managers and landlords efficiently manage their rental properties.

## 🌟 Features

### Authentication
- Secure user authentication using Firebase Auth
- Google Sign-in integration
- User settings persistence
- Role-based access control

### Dashboard
- Interactive analytics charts using fl_chart
- Real-time statistics and counters
- Staggered grid layout for data visualization
- Shimmer loading effects for better UX

### Tenant Management
- Complete tenant information tracking
- Provider-based state management for real-time updates
- Tenant history and documentation
- Rent tracking and management

### Complaints System
- File upload support for documentation
- Time-based complaint tracking
- Interactive slidable UI for complaint management
- Historical complaint records

## 🛠 Technical Implementation

### State Management
- Provider pattern for state management
- Multiple providers handling different aspects:
  - AuthProvider: Authentication state
  - NavigationProvider: App navigation state
  - TenantProvider: Tenant data management
  - UserSettingsProvider: User preferences

### Backend
- Firebase Firestore for data storage
- Real-time data synchronization
- Cloud-based file storage
- Secure data access rules

### UI/UX
- Material Design 3 implementation
- Custom navigation using Google Navigation Bar
- Responsive layout supporting multiple screen sizes
- Smooth animations and transitions
- Interactive charts and grids

## 🚀 Getting Started

### Prerequisites
1. Flutter SDK (>=3.0.0)
2. Firebase project setup
3. Google Cloud Platform project (for Google Sign-in)

### Setup Instructions

1. Clone the repository
```bash
git clone [repository-url]
cd kiraya
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure Firebase
- Create a new Firebase project
- Add your Firebase configuration files:
  - For Android: `google-services.json` in `android/app`
  - For iOS: `GoogleService-Info.plist` in `ios/Runner`
- Update Firebase configuration in the project

4. Run the application
```bash
flutter run
```

## 📱 Platform Support

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 📚 Dependencies

### Core
- `firebase_core`, `firebase_auth`, `cloud_firestore`: Firebase integration
- `google_sign_in`: Google authentication
- `provider`: State management

### UI Components
- `google_nav_bar`: Custom navigation
- `fl_chart`: Interactive charts
- `flutter_staggered_grid_view`: Dashboard layouts
- `shimmer`: Loading effects
- `flutter_slidable`: Interactive list items

### Utils
- `intl`: Internationalization
- `timeago`: Relative time calculations
- `path_provider`: File system access
- `url_launcher`: External URL handling

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check [issues page](issues-link).

## 📄 License

This project is [MIT](license-link) licensed.
