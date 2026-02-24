# Guard App 🚨

## Overview

Guard App is the **service provider application** in the Zaburb Internship Task.
Guards can:

* Login using phone authentication
* Setup profile
* Toggle Online / Offline status
* Share live location (background update)
* Receive customer ride requests
* Accept / Reject rides
* Track active rides
* Complete rides

The app continuously updates guard location to Firebase Firestore when online.

---

## Features

### 🔐 Authentication

* Firebase Phone OTP Authentication
* Session persistence (auto login)

### 👤 Guard Profile

* Profile setup stored in Firestore
* Guard data stored in:

```
guards/{guardId}
```

---

### 🟢 Online / Offline System

* Guard can toggle availability
* Updates Firestore:

```
isOnline: true / false
```

---

### 📍 Background Location Tracking

* Location updates every few seconds
* Works even when app is minimized
* Data stored:

```
latitude
longitude
```

---

### 📦 Ride Management

Guard can:

* View pending ride requests
* Accept or reject rides
* View active ride
* Finish ride

Ride status flow:

```
pending → accepted → completed
```

---

### 🔔 New Request Alert

* Snackbar notification shown when new request arrives.

---

## Architecture

### State Management

* BLoC Pattern

Used for:

* Guard online/offline state
* Background tracking control

---

### Service Layer

Firestore operations are separated via:

```
RideService
```

(UI does NOT directly manage database logic)

---

## Firebase Collections

### guards

```
uid
name
isOnline
latitude
longitude
```

### rides

```
customerId
guardId
status
bookingDate
bookingTime
latitude
longitude
timestamp
```

---

## Tech Stack

* Flutter
* Firebase Auth
* Cloud Firestore
* Geolocator
* Flutter Background Service
* Google Maps
* Flutter BLoC

---

## Setup

### 1. Install dependencies

```
flutter pub get
```

### 2. Configure Firebase

Add:

```
android/app/google-services.json
```

---

### 3. Run app

```
flutter run
```

---

## Demo Flow

1. Login via OTP
2. Setup profile
3. Go online
4. Location updates in Firestore
5. Receive customer request
6. Accept ride
7. Track ride
8. Finish ride

---

## Internship Task Coverage

✔ Phone Authentication
✔ Profile Setup
✔ Guard Availability
✔ Background Location Tracking
✔ Ride Accept / Reject
✔ Ride Completion
✔ Firestore Integration
✔ Clean Architecture (Service Layer)

---

## Author

Ezio
