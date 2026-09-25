# Aura Drive - Vehicle Telemetry & Monitoring System

## Design Tokens & Theme Specification

This color system is standardized across both the **Flutter frontend** (`flutter_app/lib/theme/app_theme.dart`) and the **Web/HTML interfaces** (`index.html`). All subsequent screens (telemetry dashboards, battery diagnostics, ECU alerts, GPS route tracker) should reuse these tokens.

### 🎨 Color Palette

| Token | Hex Value | Role / Usage |
|---|---|---|
| **Primary** | `#006A68` | Main brand teal, active buttons, active tabs, header highlights |
| **Primary Container** | `#2BB5B2` | Gradient start, active telemetry badges, live pulse dots |
| **Primary Fixed Dim** | `#5BD9D6` | Ambient atmospheric background glow, accent borders |
| **Primary Fixed** | `#7BF6F2` | Electric cyan highlights, high-visibility metric indicators |
| **Secondary** | `#4D6262` | Subtitle text, secondary label icons, CAN-Bus labels |
| **Secondary Container** | `#D0E7E6` | Light teal pills, success/system alert background tint |
| **Tertiary** | `#006A67` | Deep contrast accent, telemetry module badges |
| **Tertiary Fixed Dim** | `#75D6D2` | Secondary atmospheric ambient glow orb |
| **Background / Surface** | `#F4FAFA` | Pristine clinical EV body background, canvas fill |
| **Surface Container** | `#E9EFEF` | Tab switcher background, card container backdrop |
| **Surface Container High**| `#E3E9E9` | Elevated card surfaces |
| **On Surface (Text)** | `#161D1D` | Primary typography & high contrast heading text |
| **On Surface Variant** | `#3D4948` | Field labels, descriptive text, metadata |
| **Outline** | `#6C7A79` | Icon borders, subtle input boundaries |
| **Outline Variant** | `#BCC9C8` | Divider lines, unfocused borders |
| **Error** | `#BA1A1A` | Validation errors, ECU fault alerts |
| **Success** | `#10B981` | Online status, successful telemetry sync |

---

### ✨ Glassmorphism Specification
- **Panel Surface**: `rgba(255, 255, 255, 0.78)`
- **Backdrop Blur**: `20px - 24px`
- **Border**: `1px solid rgba(255, 255, 255, 0.85)` with linear gradient accent
- **Shadow**: `0 24px 48px -12px rgba(0, 106, 104, 0.14)`

---

### 🔤 Unified Typography Specification

| Role | Font Family | Weights | Usage |
|---|---|---|---|
| **Headlines & Display** | `Outfit`, `Inter`, sans-serif | 600, 700, 800 | Section headers, card titles, hero branding, modal headers |
| **Body & UI** | `Inter`, -apple-system, sans-serif | 400, 500, 600 | Body paragraphs, form controls, table data, subheadings |
| **Monospace / Telemetry** | `JetBrains Mono`, SF Mono, monospace | 500, 600, 700 | License plates (HSRP), transaction IDs, RFID serials, CAN-bus logs |

---

### 📁 Project Architecture

```
c:\z_motoro/
├── index.html                   # Improved high-aesthetic web login & vehicle registration page
├── COLOR_THEME_GUIDE.md         # Unified design tokens & theme documentation
├── backend/                     # Python Backend Services (FastAPI)
│   ├── main.py                  # Auth endpoints (/api/v1/auth/login) & Telemetry API
│   └── requirements.txt         # FastAPI, Uvicorn, Pydantic
└── flutter_app/                 # Dart / Flutter Application
    ├── pubspec.yaml             # Flutter dependencies
    └── lib/
        ├── main.dart            # App entrypoint with AuraDriveApp
        ├── theme/
        │   └── app_theme.dart   # Centralized theme tokens, colors, & decorations
        └── screens/
            └── login_screen.dart # Production-ready glassmorphic Flutter login screen
```

---

### 🚀 Running the Services

#### 1. Web Preview (Direct HTML)
Simply open `index.html` in any browser or serve via a local server:
```bash
python -m http.server 3000
```
Then visit `http://localhost:3000`.

#### 2. Flutter App (Dart)
```bash
cd flutter_app
flutter run
```
Supports Web (`flutter run -d chrome`), Windows desktop (`flutter run -d windows`), Android, and iOS.

#### 3. Python Backend (FastAPI)
```bash
cd backend
pip install -r requirements.txt
python main.py
```
API Documentation will be live at `http://localhost:8000/docs`.
