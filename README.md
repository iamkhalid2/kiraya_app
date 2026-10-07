# Kiraya - Rental Property Management System

A modern Flutter application for managing rental properties, tenants, and rent collection. Built with Firebase backend for real-time data synchronization and secure authentication.

## ✨ Features

### Authentication
- Email/Password and Google Sign-in integration
- Secure Firebase Authentication
- Persistent user sessions
- Password reset functionality

### Dashboard
- Real-time revenue analytics
- Occupancy statistics
- Payment status tracking
- Monthly income visualization using fl_chart
- At-a-glance property overview

### Room Management
- Dynamic room configuration
- Section-wise occupancy tracking (A, B, C, D)
- Visual room status indicators
- Configurable room limits
- Real-time availability updates

### Tenant Management
- Comprehensive tenant profiles
- KYC document storage
- Rent payment tracking
- Contact information management
- Payment history
- Due date reminders

### Settings & Configuration
- Property configuration
- Room limit management
- Theme customization options
- User preferences

## 🛠 Tech Stack

### Frontend
- Flutter SDK (>=3.0.0)
- Material Design 3
- Provider for state management
- Responsive UI design

### Backend
- Firebase Authentication
- Cloud Firestore
- Firebase Storage
- Real-time data synchronization

### Key Packages
- `provider`: State management
- `cloud_firestore`: Database operations
- `firebase_auth`: Authentication
- `google_sign_in`: OAuth integration
- `fl_chart`: Analytics visualization
- `google_nav_bar`: Navigation
- `flutter_staggered_grid_view`: Dashboard layout
- `image_picker`: Document upload
- `url_launcher`: External communications

## 🚀 Getting Started

1. Clone the repository
```bash
git clone <repository-url>
cd kiraya
```

2. Install dependencies
```bash
flutter pub get
```

3. Firebase Setup
- Create a new Firebase project
- Enable Authentication (Email/Password and Google Sign-in)
- Set up Cloud Firestore
- Download and add Firebase configuration files:
  - Android: Place `google-services.json` in `android/app/`
  - iOS: Place `GoogleService-Info.plist` in `ios/Runner/`
  - Configure web platform if needed

4. Run the application
```bash
flutter run
```

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 🔒 Environment Setup

Required environment variables and configurations:
- Firebase configuration
- Google Sign-in client IDs
- Minimum Flutter SDK version: 3.0.0

## 🤝 Contributing

Contributions welcome! Please feel free to submit pull requests.

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📝 License

This project is licensed under the BUSL-1.1 License - see the [LICENSE](LICENSE) file for details.

## 🛡️ Security

All sensitive files are ignored in version control:
- Firebase configuration files
- Google Services configuration
- Keystore files
- Local properties
- Build outputs

## 📞 Support

For support, please open an issue in the repository.
