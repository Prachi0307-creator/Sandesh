# 📬 Sandesh - Real-Time Chat Application

**Sandesh** is a real-time, cross-platform messaging app built using Flutter and powered by Firebase. It allows users to send and receive messages instantly, share images, and stay connected with a simple, intuitive UI.

---

## 🚀 Features

- 🔐 **User Authentication** (Email & Password)
- 💬 **One-to-One Messaging**
- 🔁 **Real-Time Chat** with Firebase Cloud Firestore
- 🖼️ **Image/File Sharing** using Firebase Storage
- 🧠 **Clean & Responsive UI** with Flutter
- 🔒 **Secure & Scalable** backend using Firebase

---

## 🛠️ Tech Stack

| Layer       | Technology        |
|-------------|-------------------|
| Frontend    | Flutter (Dart)    |
| Backend     | Firebase          |
| Database    | Cloud Firestore   |
| Storage     | Firebase Storage  |
| Auth        | Firebase Auth     |

---

## 📂 Project Structure
lib/
├── main.dart                # Entry point of the app
│
├── screens/                # UI screens for navigation
│   ├── login_screen.dart         # Login page UI
│   ├── signup_screen.dart        # Signup page UI
│   └── chat_screen.dart          # Main chat interface
│
├── services/               # Firebase and authentication services
│   ├── auth_service.dart         # Handles login, signup, logout
│   └── chat_service.dart         # Send/receive message logic
│
├── models/                 # Data models used in the app
│   ├── user_model.dart           # User info structure
│   └── message_model.dart        # Chat message structure
│
├── widgets/                # Reusable widgets across the app
│   ├── chat_bubble.dart          # Message bubble UI component
│   └── custom_textfield.dart     # Custom text input field
│
└── utils/                  # Utility classes/functions
    └── constants.dart            # App-wide constants like colors, styles



---

## ⚙️ Firebase Setup

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Enable the following services:
   - Email/Password Authentication
   - Cloud Firestore
   - Firebase Storage
3. Set proper Firestore and Storage rules for authenticated access.
4. Download `google-services.json` and place it inside `android/app/`
5. For iOS, download `GoogleService-Info.plist` and add it to your Xcode project.

---

## 🧪 How to Run the App

```bash
# 1. Clone the repository
git clone https://github.com/Prachi0307-creator/Sandesh.git
cd Sandesh

# 2. Get Flutter packages
flutter pub get

# 3. Run the app
flutter run

```

## 🙋‍♀️ Author

**Prachi Bhardwaj**  
🔗 [GitHub](https://github.com/Prachi0307-creator)  
📧 prachibhardwaj0307@gmail.com  
🔗 [LinkedIn](https://www.linkedin.com/in/prachi-bhardwaj-896689248)

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
