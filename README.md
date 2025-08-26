HotelBookingApp
A hotel booking application developed to assist users in searching, booking, and managing accommodation information easily and efficiently. This is a project for the "Mobile Device Programming" course at Ho Chi Minh City University of Foreign Languages and Information Technology.
Introduction
The "HotelBookingApp" project is a mobile application that allows users to search for and book hotels, as well as manage personal information and booking history. It also provides a management interface for hotels to update room statuses and handle bookings. With a user-friendly interface, the app aims to deliver a seamless experience for both regular users and hotel administrators.
Key Features

Registration, Login, Password Recovery: Supports login/registration via email or Google account, and password recovery via email.
Hotel Search and Filtering: Search hotels by location, room type, price, and check-in/check-out dates.
Online Booking: View room details and book instantly.
Booking Management: View, edit, or cancel bookings.
Personal Information Management: Update and manage user account information.
Service Reviews: Submit ratings and feedback on hotel services.
Favorite Rooms: Save favorite rooms for later viewing.
Hotel Management: Administrators can update room statuses and manage bookings.
Notifications: Send booking schedule notifications via email or in-app.
Location and Transportation: Supports hotel location lookup and transportation booking.

Project Structure
HotelBookingApp/
├── assets/             # Images, logos, static resources
├── lib/                # Main source code of the application
│   ├── models/         # Data models (User, Room, Booking, etc.)
│   ├── pages/          # Interface pages (Home, Search, Profile, etc.)
│   ├── screens/        # Main screens (Login, Register, Splash, etc.)
│   ├── services/       # Services (API, Authentication, etc.)
│   ├── widgets/        # Reusable UI components
├── pubspec.yaml        # Flutter dependencies configuration file
└── README.md           # Project guide file

Technologies

Frontend: Flutter (Dart) - Cross-platform framework for Android, iOS, and Web.
Interface Design: Figma - UI/UX design tool.
Backend: Firebase (Authentication, Database) and RESTful API.
Supporting Tools: Git, GitHub, Firebase CLI.

System Requirements

Flutter SDK: 3.0 or higher
Dart: 2.12 or higher
Android Studio or VS Code
Git
Firebase CLI (for backend configuration)

Installation and Running

Clone the repository:
git clone https://github.com/NganHa9797/HotelBookingApp.git
cd HotelBookingApp


Install dependencies:
flutter pub get


Configure Firebase:

Visit Firebase Console and create a project.
Download the google-services.json (Android) or GoogleService-Info.plist (iOS) configuration file and place it in the android/app or ios/Runner directory.
Update API information in the project configuration file (if needed).


Run the application:
flutter run


Test on a device or emulator:

Ensure the Flutter environment is set up as per the official guide.
Select an Android/iOS device or emulator to run the app.



Contributors
Thank you to the team members who collaborated to complete the application:

Hoàng Ngân Hà - FE+BE: Booking, Google login/registration, password recovery, reviews, favorites, booking history.
Trần Bảo Ngọc - FE: Homepage, location, reviews, favorites.
Phan Long Phi - FE: Search, amenities filter.
Vũ Nguyễn Nam Phúc - FE+BE: Profile, user information management.

Note: The GitHub link for Phan Long Phi is not provided. Please update if available.
References

Flutter Documentation
Figma
Firebase Documentation
Stack Overflow
ChatGPT

Project Links

Figma Design: Figma Link
Tutorial Video: YouTube

