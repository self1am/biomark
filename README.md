# Biomark Mobile Application

**Biomark** is a Flutter-based mobile application developed for a research organization that collects personal data from volunteers for building predictive machine learning models. This app handles user registration, login, profile management, and account recovery using Firebase Authentication and local SQLite storage.

## Features
- **User Registration**: Users can create an account with email and password.
- **User Login**: Firebase Authentication is used for secure login.
- **Profile Management**: Users can view and manage personal information.
- **Account Recovery**: Recover user accounts using security questions.
- **Data Persistence**: Sensitive data is securely stored locally using SQLite.

## Technology Stack
- **Frontend**: Flutter (Dart)
- **Backend**: Firebase Authentication, Firebase Firestore (future integration)
- **Database**: SQLite (local storage)

## Getting Started

### Prerequisites

- Flutter SDK: [Install Flutter](https://flutter.dev/docs/get-started/install)
- Android Studio / Xcode: For Android and iOS builds.
- Firebase Account: Create a project in [Firebase Console](https://console.firebase.google.com/).

### Project Setup

1. **Clone the repository**:

   ```bash
   git clone https://github.com/your-username/biomark.git
   cd biomark
   ```

2. **Install dependencies**:

   Run the following command to install the required Flutter dependencies:

   ```bash
   flutter pub get
   ```

3. **Firebase Setup**:

   - Go to the [Firebase Console](https://console.firebase.google.com/).
   - Create a new project or use an existing one.
   - Register your Android app with the package name `com.majestta.biomark`.
   - Download the `google-services.json` file from the Firebase Console.
   - Place the `google-services.json` file in the `android/app/` directory of your project.

4. **Environment Variables**:

   Set up environment variables to handle API keys and other sensitive data. You can use the `flutter_dotenv` package for this:

   - Create a `.env` file in the root of your project:

     ```bash
     touch .env
     ```

   - Add your API keys and sensitive values to this file:

     ```
     API_KEY=your_firebase_api_key_here
     ```

   - Ensure that your `.env` file is ignored by Git by adding it to `.gitignore`:

     ```
     .env
     ```

   - Load environment variables in your `main.dart`:

     ```dart
     import 'package:flutter_dotenv/flutter_dotenv.dart';

     Future<void> main() async {
       await dotenv.load(fileName: ".env");
       runApp(MyApp());
     }
     ```

5. **Ignore Sensitive Files**:

   Make sure the following files are added to `.gitignore` to avoid pushing sensitive information to version control:

   ```
   android/app/google-services.json
   .env
   ```

   If you’ve already pushed these files to Git, remove them from tracking with:

   ```bash
   git rm --cached android/app/google-services.json
   git rm --cached .env
   ```

6. **Run the app**:

   - For Android:

     ```bash
     flutter run
     ```

   - For iOS:

     ```bash
     flutter run --release
     ```

### Firebase Configuration (Android)

- Ensure that the `google-services.json` file is placed in the `android/app/` directory.
- Firebase Authentication is used for login, registration, and user management.
- To manage Firebase keys and security, rotate keys periodically and restrict API usage.

### Additional Configurations

- **API Key Restrictions**: You can restrict the Firebase API key to only be used by your app. Go to the Firebase Console, navigate to **APIs & Services > Credentials**, and set restrictions for your API key.
  
## Running Tests

You can run tests by using the following Flutter command:

```bash
flutter test
```

## Deployment

1. **Building APK for Android**:

   ```bash
   flutter build apk --release
   ```

2. **Building for iOS**:

   ```bash
   flutter build ios --release
   ```

## Security Considerations

1. **API Key Management**:
   - Ensure API keys are not exposed in the codebase. Use environment variables for storing sensitive data.
   - Add the `google-services.json` and `.env` files to `.gitignore` to avoid pushing them to version control.
   
2. **Firebase Security**:
   - Restrict API key usage to authorized apps only.
   - Regularly monitor Firebase usage and security settings.

## Contributing

Contributions are welcome! Please follow the [Contributor Guidelines](CONTRIBUTING.md) for more information.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

### Final Notes

- Always remember to secure your Firebase API keys and configuration files.
- Follow best practices for sensitive data management by using environment variables and proper `.gitignore` entries.

Feel free to modify this README to better suit your project's specific needs. Let me know if you need further customization!