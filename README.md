# RESOLVE - AI-Powered Civic Grievance Platform 🏙️

[![Flutter](https://img.shields.io/badge/Flutter-3.29.3-02569B?logo=flutter)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase)](https://firebase.google.com/)
[![Gemini AI](https://img.shields.io/badge/Gemini_AI-Integrated-4285F4?logo=google)](https://ai.google.dev/)

## 🌟 Overview

RESOLVE is a modern, AI-powered civic complaint management system that transforms how citizens report issues and how authorities respond. Built with Flutter and Firebase, it features intelligent photo verification, automated severity analysis, and a smart chatbot assistant.

### ✨ Key Features

- 🤖 **AI-Powered Photo Verification** - Gemini AI detects spam and validates complaint photos
- 📊 **Smart Severity Analysis** - Automatic priority assignment based on AI analysis
- 💬 **Intelligent Chatbot** - 24/7 AI assistant to help citizens use the app
- 📱 **Real-time Tracking** - Swiggy-style progress tracking for complaints
- 🔐 **Secure Authentication** - Firebase Auth with Google Sign-In for citizens
- 👥 **Multi-Role System** - Separate interfaces for Citizens, Officials, and Admins

## 🎯 Core Capabilities

### For Citizens
- **Quick Report**: 2-tap photo upload with AI validation
- **Smart Detection**: AI automatically flags spam or irrelevant images
- **Real-time Tracking**: Track complaint status like food delivery
- **AI Chatbot**: Get instant help and answers
- **Profile Dashboard**: View active/resolved complaints and impact

### For Officials
- **Task Management**: Prioritized complaint dashboard
- **Status Updates**: Update complaint progress in real-time
- **Department Routing**: Complaints auto-assigned to relevant departments

### For Administrators
- **Analytics Dashboard**: Monitor performance metrics
- **Oversight**: View all complaints across departments
- **Activity Feed**: Recent actions and updates

## 🚀 Tech Stack

| Category | Technologies |
|----------|-------------|
| **Framework** | Flutter 3.29.3, Dart 3.7.2 |
| **Backend** | Firebase (Auth, Firestore, Storage) |
| **AI/ML** | Google Gemini 2.5 Flash |
| **State Management** | Provider |
| **Navigation** | GoRouter |
| **UI Components** | Material Design 3, Google Fonts |
| **Maps** | Google Maps Flutter |
| **Authentication** | Firebase Auth + Google Sign-In |

## 📁 Project Structure

```
lib/
├── core/
│   ├── config/          # AI & app configuration
│   ├── theme/           # Swiggy-inspired orange theme
│   └── router/          # Navigation setup
├── models/              # Data models
├── providers/           # State management
├── screens/
│   ├── auth/           # Login & role selection
│   ├── citizen/        # Citizen app screens
│   ├── official/       # Official dashboard
│   └── admin/          # Admin panel
├── services/
│   ├── gemini_service.dart      # AI integration
│   └── firebase_auth_service.dart
└── widgets/            # Reusable components
```

## 🛠️ Setup Instructions

### Prerequisites
- Flutter SDK 3.29.3 or higher
- Firebase project configured
- Gemini API key from [Google AI Studio](https://aistudio.google.com/app/apikey)

### 1. Clone the Repository
```bash
git clone https://github.com/Sathishraj16/RESOLVE.git
cd RESOLVE
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configure Firebase
1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add your `google-services.json` to `android/app/`
3. Add your `GoogleService-Info.plist` to `ios/Runner/`
4. Enable Firebase Authentication (Google Sign-In)
5. Create Firestore database

### 4. Configure Gemini AI
1. Get API key from [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Create `lib/core/config/ai_config.dart`:
```dart
class AIConfig {
  static const String geminiApiKey = 'YOUR_API_KEY_HERE';
  // ... rest of config
}
```

### 5. Setup Firestore Collections
Manually add test accounts to Firestore:

**Officials Collection:**
```json
{
  "id": "official_001",
  "name": "Officer Smith",
  "email": "officer@example.com",
  "password": "password123",
  "role": "official",
  "department": "Public Works"
}
```

**Admins Collection:**
```json
{
  "id": "admin_001",
  "name": "Admin Kumar",
  "email": "admin@example.com",
  "password": "admin123",
  "role": "admin",
  "department": "Administration"
}
```

### 6. Run the App
```bash
# For Android
flutter run -d android

# For iOS
flutter run -d ios

# For Web
flutter run -d chrome
```

## 🔑 Demo Credentials

| Role | Email | Password |
|------|-------|----------|
| **Citizen** | Use Google Sign-In | - |
| **Official** | officer@example.com | password123 |
| **Admin** | admin@example.com | admin123 |

## 🤖 AI Features in Detail

### Photo Verification
- **Spam Detection**: Identifies random/irrelevant images
- **Category Matching**: Verifies photo matches complaint type
- **Confidence Scoring**: Provides verification confidence level

### Severity Analysis
- **Automated Prioritization**: Analyzes complaint urgency (1-5 scale)
- **Context-Aware**: Considers impact, safety, and affected population
- **Explanation**: Provides reasoning for severity rating

### Chatbot Assistant
- **24/7 Support**: Answers questions about using the app
- **Contextual Help**: Understands RESOLVE features
- **Friendly Guidance**: Encourages civic participation

## 📱 Screenshots

| Citizen Home | Report Issue | AI Verification |
|--------------|-------------|----------------|
| Quick access to report | Photo upload + AI check | Spam detection in action |

| Official Dashboard | Admin Panel | Chatbot |
|-------------------|------------|---------|
| Task management | Analytics overview | AI assistant |

## 🔒 Security Features

- Firebase Authentication with Google Sign-In
- Role-based access control
- Secure API key management
- Firestore security rules
- Input validation and sanitization

## 🌍 Supported Platforms

- ✅ Android (API 21+)
- ✅ iOS (11.0+)
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 📈 Future Enhancements

- [ ] Push notifications for status updates
- [ ] Offline mode with sync
- [ ] Multi-language support
- [ ] Voice complaint reporting
- [ ] Advanced analytics dashboard
- [ ] Community voting on complaints
- [ ] Heatmap visualization
- [ ] SMS alerts for officials

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Developer

**Sathishraj**
- GitHub: [@Sathishraj16](https://github.com/Sathishraj16)

## 🙏 Acknowledgments

- Google Gemini AI for intelligent features
- Firebase for backend infrastructure
- Flutter team for the amazing framework
- Swiggy/Zomato for UI/UX inspiration

## 📞 Support

For support, email your-email@example.com or create an issue in the repository.

---

Built with ❤️ for better governance and civic engagement
