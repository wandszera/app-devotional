# 📱 Devotional App

> A modern platform for daily spiritual development, focused on helping users build and maintain a daily reading habit through smart gamification and efficient reminders.

---

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/FastAPI-0.100.0+-009688?style=for-the-badge&logo=fastapi&logoColor=white" alt="FastAPI" />
  <img src="https://img.shields.io/badge/Python-3.10+-3776AB?style=for-the-badge&logo=python&logoColor=white" alt="Python" />
  <img src="https://img.shields.io/badge/SQLite-3.x-003B57?style=for-the-badge&logo=sqlite&logoColor=white" alt="SQLite" />
  <img src="https://img.shields.io/badge/Windows-Supported-0078D4?style=for-the-badge&logo=windows&logoColor=white" alt="Windows" />
</p>

---

## 🧭 Table of Contents

- [🔍 Overview](#-overview)
- [🏗️ System Architecture](#%EF%B8%8F-system-architecture)
- [📁 Repository Structure](#-repository-structure)
- [⚡ Backend (FastAPI)](#-backend-fastapi)
  - [API Endpoints](#api-endpoints)
  - [How to Run the Backend](#how-to-run-the-backend)
  - [How to Run Tests](#how-to-run-tests)
- [📱 Mobile (Flutter)](#-mobile-flutter)
  - [How to Run the Mobile App](#how-to-run-the-mobile-app)
- [🎯 Engagement Loop & Streak Rules](#-engagement-loop--streak-rules)
- [📈 Development Roadmap](#-development-roadmap)
- [🔗 Useful Documents](#-useful-documents)

---

## 🔍 Overview

This repository contains the complete source code for the **Devotional App**, divided into two main modules:
1. **Backend**: A high-performance RESTful API built with **FastAPI** and a relational **SQLite** database using **SQLAlchemy**.
2. **Mobile**: A cross-platform mobile application built with **Flutter**, featuring dynamic onboarding, an offline reminder flow, statistics, and full management.

---

## 🏗️ System Architecture

The communication flow and overall system architecture are structured as follows:

```mermaid
graph TD
    subgraph Client [Mobile Front-end (Flutter)]
        App[App Shell]
        Auth[Authentication & Onboarding]
        DevReader[Devotional Reader]
        ProgTab[History & Streaks]
        AdminPanel[Flutter Admin Panel]
    end

    subgraph Server [API Back-end (FastAPI)]
        Router[Main Router / API]
        AuthSvc[Authentication Service]
        StreakSvc[Streak Engine]
        NotifSvc[Notification Scheduler]
        AdminSvc[Content Manager]
    end

    subgraph Persistence [Database]
        DB[(devotional.db SQLite)]
    end

    App -->|HTTP/REST with JSON| Router
    Router --> AuthSvc
    Router --> StreakSvc
    Router --> NotifSvc
    Router --> AdminSvc
    
    AuthSvc --> DB
    StreakSvc --> DB
    NotifSvc --> DB
    AdminSvc --> DB
```

---

## 📁 Repository Structure

```text
app_devocional/
├── app/                  # Backend API source code (FastAPI)
│   ├── api/              # API configurations and middlewares
│   ├── core/             # System and security configurations
│   ├── db/               # Database session and engine (SQLAlchemy)
│   ├── models/           # ORM data models
│   ├── routes/           # Routes divided by modules (auth, devotional, etc.)
│   └── services/         # Core business logic (streaks, notifications)
├── docs/                 # Documentation and product strategic roadmap
├── mobile/               # Cross-platform mobile application project (Flutter)
│   ├── lib/              # Dart code structured into features and services
│   └── test/             # Flutter unit and widget tests
├── tests/                # Backend unit and integration tests (Pytest)
├── make_admin.py         # Utility script to promote users to administrator
└── requirements.txt      # Python library dependencies
```

---

## ⚡ Backend (FastAPI)

The project backend manages authentication logic (JWT), consecutive streak business rules, daily reminder notification preferences persistence, and provides administrative dashboards.

### API Endpoints

The table below details all current routes and authorization rules:

| Method | Endpoint | Authentication | Admin Access | Description |
| :--- | :--- | :---: | :---: | :--- |
| `POST` | `/auth/register` | ❌ | ❌ | Registers a new user and returns an access token. |
| `POST` | `/auth/login` | ❌ | ❌ | Authenticates a user and returns a JWT access token. |
| `GET` | `/auth/me` | 🔒 Bearer | ❌ | Returns the authenticated user's profile details. |
| `GET` | `/devotional/today` | 🔒 Bearer | ❌ | Gets the available devotional for the current day. |
| `POST` | `/devotional/complete` | 🔒 Bearer | ❌ | Marks today's devotional as read and updates the streak. |
| `GET` | `/devotional/admin` | 🔒 Bearer |  Admin | Lists all devotionals (for administrative purposes). |
| `POST` | `/devotional/admin` | 🔒 Bearer |  Admin | Creates a new devotional. |
| `PUT` | `/devotional/admin/{id}` | 🔒 Bearer |  Admin | Updates an existing devotional by ID. |
| `DELETE` | `/devotional/admin/{id}` | 🔒 Bearer |  Admin | Deletes a specific devotional by ID. |
| `GET` | `/notifications/settings` | 🔒 Bearer | ❌ | Retrieves the user's notification preferences. |
| `PUT` | `/notifications/settings` | 🔒 Bearer | ❌ | Updates notification time and timezone settings. |
| `GET` | `/notifications/admin/due` | 🔒 Bearer |  Admin | Queries pending notifications to be sent. |
| `POST` | `/notifications/admin/dispatch` | 🔒 Bearer |  Admin | Triggers batch sending of scheduled notifications. |
| `GET` | `/notifications/admin/deliveries` | 🔒 Bearer |  Admin | Displays the notification delivery history. |
| `POST` | `/notifications/admin/{user_id}/mark-sent` | 🔒 Bearer |  Admin | Records manual notification delivery for a specific user. |
| `GET` | `/streak` | 🔒 Bearer | ❌ | Returns the user's current and longest streak status. |
| `GET` | `/progress` | 🔒 Bearer | ❌ | Returns the monthly reading history and completed days. |
| `GET` | `/health` | ❌ | ❌ | Simple service health and monitoring endpoint. |

### How to Run the Backend

1. **Clone the repository** and enter the root directory.
2. **Create and activate a virtual environment** in Python:
   ```bash
   python -m venv .venv
   # On Windows (PowerShell):
   .venv\Scripts\Activate.ps1
   # On macOS/Linux:
   source .venv/bin/activate
   ```
3. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```
4. **Run the development server** via Uvicorn:
   ```bash
   python -m uvicorn app.main:app --reload
   ```
5. **Access the interactive documentation**:
   - Swagger UI: [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)
   - Redoc: [http://127.0.0.1:8000/redoc](http://127.0.0.1:8000/redoc)

### How to Run Tests

We use [pytest](https://pytest.org/) for backend unit and integration test coverage.
```bash
python -m pytest -q
```

---

## 📱 Mobile (Flutter)

The mobile app is built in Flutter and designed to work perfectly responsively. It features interactive onboarding, visual daily achievement dashboards, and a dedicated admin area.

> [!NOTE]
> By default, the app points to `http://10.0.2.2:8000` (native resolution for the Android emulator to point to the local machine). 
> If you are running on desktop platforms, web, or iOS simulator, you can set the environment variable during runtime or modify the corresponding service file.

### How to Run the Mobile App

1. Navigate to the `mobile/` folder:
   ```bash
   cd mobile
   ```
2. Create or update the necessary platforms:
   ```bash
   flutter create --platforms=windows,web .
   ```
3. Install the Pubspec packages and dependencies:
   ```bash
   flutter pub get
   ```
4. Run the application passing the local API host:
   
   **On Windows**:
   ```bash
   flutter run -d windows --dart-define=API_BASE_URL=http://127.0.0.1:8000
   ```

   **On Browser (Web)**:
   ```bash
   flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000
   ```

   **On Android Emulator**:
   ```bash
   flutter run -d android --dart-define=API_BASE_URL=http://10.0.2.2:8000
   ```

---

## 🎯 Engagement Loop & Streak Rules

The success of the application is measured based on the user's constant return. The core engagement loop consists of:
1. **Daily Notification**: The user receives an alert at their preferred time.
2. **Reading**: Opening the app and reading the daily devotional.
3. **Completion**: The user marks the devotional as read.
4. **Gratification**: The user's streak count increases, and visual achievements are unlocked.

### Streak Validation Algorithm

The daily consistency calculation logic works based on the last performed activity:
* If the user completes the devotional **today** and the last activity was **yesterday**, the streak increases by 1 day.
* If the last activity was **today**, the streak remains unchanged.
* If the last activity occurred **more than 1 day ago**, the streak is reset and restarts at 1 day.

---

## 📈 Development Roadmap

- [x] **Phase 1: Core MVP (Focus on Retention)**
  - Login and registration system.
  - Display devotionals and daily reading tracking.
  - Logic and display of consecutive streaks.
  - Basic monthly progress screen and history.
- [ ] **Phase 2: Gamification and Refinements**
  - Achievement milestones and badges (e.g., 7 days, 30 days of reading).
  - Animations and sound feedback upon completing a day.
  - More robust scheduled local notifications.
- [ ] **Phase 3: Monetization and Freemium**
  - Controlled ad implementation.
  - Premium plan with exclusive devotionals and expanded history.
  - In-app subscriptions configuration.
- [ ] **Phase 4: Content Expansion**
  - Audio player to listen to the daily devotional.
  - Personal notes system linked to each reading day.

---

## 🔗 Useful Documents

* [Product Roadmap Documentation](file:///c:/Users/wand/Desktop/projetos_pessoais/app_devocional/docs/product-roadmap.md) - Detailed strategic vision, initial scope, and business rules.
* [Mobile Module Documentation](file:///c:/Users/wand/Desktop/projetos_pessoais/app_devocional/mobile/README.md) - In-depth step-by-step, deployment instructions, and specific Flutter app troubleshooting.
