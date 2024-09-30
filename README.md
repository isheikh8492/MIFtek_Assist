# MIFtek Assist

## Overview

**MIFtek Assist** is a cross-platform application built using Flutter, aimed at helping engineers and technical users manage procedures easily. The app supports Android, Windows, and web environments, providing a user-friendly experience with a focus on procedure management. Users can add, edit, bookmark, and categorize procedures, and utilize the search functionality for efficient navigation.

## Features

- **Cross-Platform Support**: The app runs on Android, Windows, and the web.
- **Authentication**: Uses Firebase Authentication for secure user login and registration.
- **Admin and User Roles**: The admin account (`admin@miftek.com`) has extra privileges to manage topics and procedures. Currently, there is no functionality to add additional administrators.
- **Topics and Procedures**: Users can create, organize, and edit procedures categorized under different topics.
- **Bookmarking**: Users can bookmark procedures for easy access.
- **Real-Time Sync**: Firebase Firestore provides real-time data synchronization across all platforms.
- **Search Functionality**: Users can search for procedures by title or category.

## Live Demo

The web version of the app is hosted using Firebase Hosting and can be accessed here:

- [MIFtek Assist Web App](https://miftek-assist.web.app)

## Installation

### 1. Download the Executable Files

You can test MIFtek Assist on different platforms using the provided download links:

- **Android APK**: [Download APK](https://example.com/miftek_assist.apk)
  - Install the APK by copying it to your Android device and opening it, or using `adb install app-release.apk` via command line.
  
- **Windows Executable**: [Download Windows EXE](https://example.com/miftek_assist.exe)
  - Simply download the `.exe` file and run it on your Windows machine.

### 2. Running the Web Version

You can run the web version by visiting the following link:

- [MIFtek Assist Web App](https://miftek-assist.web.app)

### 3. Cloning the Repository and Building Yourself

If you're interested in making modifications to the app or exploring the code, you can clone the repository and set it up yourself.

#### Prerequisites

- **Flutter SDK**: Ensure you have Flutter installed. You can follow the instructions [here](https://docs.flutter.dev/get-started/install).
- **Firebase Account**: You will need to set up Firebase Authentication and Firestore for the app to work properly.

#### Clone the Repository

```bash
git clone https://github.com/yourusername/miftek_assist.git
cd miftek_assist
```

#### Setup Firebase

- Create a Firebase project in the [Firebase Console](https://console.firebase.google.com/).
- Enable Firebase Authentication and Firestore.
- Add the configuration file (`google-services.json` for Android and `GoogleService-Info.plist` for iOS) to the respective directories.
- Update the `firebase_options.dart` file if needed.

#### Building the App

To build the app for different platforms, use the following commands:

- **Android**: 
  ```bash
  flutter build apk
  ```
- **Windows**:
  ```bash
  flutter build windows
  ```
- **Web**:
  ```bash
  flutter build web
  ```

The output files for each platform will be located in the following directories:
- **APK**: `build/app/outputs/flutter-apk/app-release.apk`
- **Windows**: `build/windows/x64/runner/Release/miftek_assist.exe`
- **Web**: `build/web`

#### Deploying the Web Version

If you wish to host the web version yourself:

1. Install Firebase CLI: 
   ```bash
   npm install -g firebase-tools
   ```
2. Initialize Firebase Hosting in the project directory:
   ```bash
   firebase init hosting
   ```
3. Deploy to Firebase Hosting:
   ```bash
   firebase deploy
   ```

## App Access and Testing

### Admin Account
- **Email**: `admin@miftek.com`
- **Password**: (Please contact the administrator for the password)

The admin account has privileges to delete topics and procedures universally. There is no functionality currently to add additional administrators.

### User Testing
- Sign up with a new account to test the user role capabilities:
  - Add/Edit/Bookmark procedures
  - Search functionality
  - View and interact with topics and procedures

### Admin Testing
- Log in with the admin credentials:
  - Manage topics and procedures
  - Use the search functionality to locate and highlight specific procedures

## App Stack

- **Frontend**: 
  - **Flutter**: This framework enables cross-platform compatibility and a single codebase for Android, Windows, and the web.
  - **Dart**: The programming language used for building the Flutter app.

- **Backend**:
  - **Firebase Authentication**: For managing user sign-in and sign-up functionality.
  - **Firebase Firestore**: A NoSQL database used for storing all procedure-related data and user information.
  - **Firebase Hosting**: Used for deploying the web version of the app.

## Configurations

- **Firebase Setup**:
  - The project is linked to a Firebase project called "miftek-assist".
  - Firebase Firestore is used to store procedure data and user information.
  - Firebase Authentication manages the user logins and sign-ups.
  - Configuration files:
    - `.firebaserc`: Stores Firebase project association.
    - `firebase.json`: Configuration file that defines the hosting setup, such as the public directory.

- **Public Directory**: 
  - The public directory used for hosting the web assets is `build/web`, generated after running `flutter build web`.

- **Single Page Application (SPA) Configuration**:
  - All URLs are rewritten to `/index.html` to ensure that deep-linking works properly, which is typical for single-page apps.

## Limitations

### iOS and macOS Deployment
- **iOS**: Deployment for iOS is not supported since development is being done on a Windows machine. iOS builds require a macOS system and Xcode, which are unavailable on Windows.
- **macOS**: Building for macOS also requires a macOS system, which limits the development to the platforms available on Windows.

## Future Enhancements

- **Add More Admins**: Implement functionality to allow the current admin to promote other users to administrators.
- **macOS and iOS Support**: Consider expanding support by building and testing on a macOS system.
- **Offline Support Enhancement**: Expand offline functionality to include viewing and managing bookmarked procedures.

---

Feel free to reach out if you have questions or need further assistance in getting started with **MIFtek Assist**!