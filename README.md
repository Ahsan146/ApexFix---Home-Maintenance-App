# ApexFix Flutter Application

A cross-platform **Flutter & Dart** mobile and web application for **ApexFix Home Maintenance & Repair Services**.

---

## 📱 Features Included

1. **Service Categories & Catalog**:
   - AC & Cooling (HVAC), Electrical, Plumbing, Appliances, Carpentry, Solar & Inverters.
   - Price listings, detailed features, service durations, and 30-day warranty notices.

2. **4-Step Booking Workflow**:
   - Location / Address selection (Home, Office, Custom).
   - Arrival slot selection (Today urgent, Tomorrow, custom windows).
   - Problem description & notes.
   - Transparent price breakdown (Service fee, safety fee, total).

3. **Live Job Tracking & Dispatch**:
   - Real-time GPS coordinate mapping for technician and customer.
   - Dynamic radar search animation when searching for technicians.
   - Technician profile (rating, completed jobs, vehicle info LEB-4291).
   - Job progression stepper: *Finding Pro -> Technician Assigned -> En Route -> Arrived / In Progress -> Completed*.

4. **Multi-Tab Bookings Management**:
   - Active bookings, completed service history, and cancelled requests.

5. **Customer Authentication & Profile**:
   - One-click Google / Gmail sign-in.
   - Address management & customer support contacts.

---

## 🚀 How to Run the Flutter App

### Prerequisites
- Install the **Flutter SDK** (v3.0.0 or higher) from [flutter.dev](https://flutter.dev).
- Ensure an emulator or connected device is available (`flutter devices`).

### Step 1: Open Terminal in the `flutter_app` directory
```bash
cd flutter_app
```

### Step 2: Install Flutter Dependencies
```bash
flutter pub get
```

### Step 3: Run the Application
- **On Chrome / Web**:
  ```bash
  flutter run -d chrome
  ```
- **On Android Emulator / Device**:
  ```bash
  flutter run -d android
  ```
- **On iOS Simulator**:
  ```bash
  flutter run -d ios
  ```

---

## 📦 Project Structure

```
flutter_app/
├── pubspec.yaml                 # Flutter dependencies & assets configuration
├── README.md                    # Setup & architecture guide
└── lib/
    ├── main.dart                # Main entry point & bottom navigation shell
    ├── models/
    │   └── models.dart          # Data models (Booking, Customer, Technician, Address, etc.)
    ├── services/
    │   └── mock_data.dart       # Seeded categories, services, and default customer
    ├── providers/
    │   └── app_provider.dart    # State management with ChangeNotifier & actions
    └── screens/
        ├── home_screen.dart           # Home catalog & urgent booking banner
        ├── category_screen.dart       # Category services & pricing list
        ├── booking_flow_screen.dart   # Multi-step booking & scheduling flow
        ├── track_booking_screen.dart  # Real-time GPS tracking & job progression
        ├── bookings_list_screen.dart  # Active & past bookings tabs
        ├── login_screen.dart          # Google & Email authentication
        └── profile_screen.dart        # Saved addresses & account settings
```

---

## ☁️ Firebase Firestore Integration

To connect this Flutter app to your cloud Firestore database (`ai-studio-apexfixcustomera-ca71a119-f02f-421a-8717-23da1ac8b5b5`):
1. Run `flutterfire configure` in this directory to automatically link your Firebase project.
2. Initialize Firebase in `lib/main.dart`:
   ```dart
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );
   ```
3. Use the matching collections: `bookings`, `users`, `technicians`, and `services`.
