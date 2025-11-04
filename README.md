# ShopLendr

A comprehensive digital marketplace mobile application designed exclusively for University of Antique college students. ShopLendr enables students to buy, sell, and rent items within their campus community, promoting accessibility, sustainability, and community sharing.

## 📱 Overview

ShopLendr is a Flutter-based mobile application that creates a secure and accessible digital marketplace where students can:
- **Buy** items from other students
- **Sell** their own items
- **Rent** items for temporary use
- **Borrow** items from other students

## ✨ Features

### Core Functionality
- **User Authentication**: Secure registration and login system with email verification
- **Student Verification**: Gmail verification and University of Antique student ID authentication
- **Item Listing**: Users can upload item images, descriptions, categories, availability dates, and conditions
- **Real-time Filtering**: Filter items by sale and rental categories
- **In-app Messaging**: Direct communication system between users
- **Borrowing System**: Request items, communicate with lenders, and track approval/decline status
- **Product Insurance**: Insurance agreement for rental items to establish terms and reduce risk

### Technical Features
- Firebase Authentication & Firestore
- Real-time notifications (Firebase Cloud Messaging)
- Image compression and optimization
- Offline support with local caching
- Push notifications
- Analytics integration

## 🛠️ Tech Stack

- **Framework**: Flutter (Dart)
- **Backend**: Firebase
  - Authentication
  - Cloud Firestore
  - Cloud Storage
  - Cloud Messaging
  - Analytics
  - Performance Monitoring
- **State Management**: Provider
- **Routing**: GoRouter
- **UI Libraries**: 
  - Google Fonts
  - Flutter Animate
  - Font Awesome Icons

## 📋 Requirements

- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android Studio / Xcode (for mobile development)
- Firebase project setup

## 🚀 Getting Started

### Prerequisites

1. Install Flutter SDK: [Flutter Installation Guide](https://flutter.dev/docs/get-started/install)
2. Set up Firebase project:
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add Android/iOS apps to your Firebase project
   - Download configuration files (`google-services.json` for Android)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/blutech18/Shoplendr.git
cd shop_lendr3
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
   - Place `google-services.json` in `android/app/` directory
   - Configure Firebase for iOS in `ios/Runner/` directory

4. Run the application:
```bash
flutter run
```

## 📁 Project Structure

```
shop_lendr3/
├── lib/
│   ├── auth/              # Authentication related screens
│   ├── backend/           # Backend services and utilities
│   ├── chat_page/         # Messaging functionality
│   ├── components/        # Reusable UI components
│   ├── createprofile/     # Profile creation
│   ├── flutter_flow/      # Flutter Flow generated code
│   ├── homepage_copy2/    # Home page variations
│   ├── item_page/         # Item detail pages
│   ├── message/           # Messaging features
│   ├── notification_page/ # Notifications
│   ├── pages/             # Main application pages
│   ├── profile/           # User profile
│   ├── search/            # Search functionality
│   ├── app_state.dart     # Application state management
│   ├── index.dart         # Route definitions
│   └── main.dart          # Application entry point
├── android/               # Android platform files
├── ios/                   # iOS platform files
├── assets/                # Images, fonts, and other assets
├── firebase/              # Firebase configuration and functions
└── pubspec.yaml           # Flutter dependencies
```

## 🔒 Security

- User registration requires email verification
- Student ID verification for University of Antique students
- Secure Firebase Authentication
- Data security policies for user privacy
- All transactions are peer-to-peer (no payment processing)

## 📝 Notes

- **Student-Only Platform**: The platform is strictly limited to student-to-student transactions
- **No Payment Processing**: All transactions must be independently confirmed between users
- **No Admin Approval**: Users can post items without admin approval for seamless listing
- **Peer-to-Peer Delivery**: Users arrange delivery or meet-ups independently

## 🤝 Contributing

This project is developed for University of Antique students. Contributions and suggestions are welcome!

## 📄 License

This project is developed for academic/research purposes.

## 👥 Authors

Developed by BluTech18

## 🔗 Repository

[GitHub Repository](https://github.com/blutech18/Shoplendr.git)

---

**Note**: This application is designed exclusively for University of Antique college students. All users must verify their student status through email and student ID verification.
