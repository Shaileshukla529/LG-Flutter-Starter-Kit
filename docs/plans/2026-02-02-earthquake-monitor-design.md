# design: Earthquake & Natural Disaster Monitor

## 1. Project Overview
A real-time "Command Center" dashboard for Liquid Galaxy that visualizes global seismic activity. The application transforms the LG rig into a 3D structural display where earthquakes appear as extruded bars rising from the earth's surface.

**Goal:** Create a visually stunning, high-performance demo that highlights significant natural events using the full power of the panoramic display.

## 2. Core Features

### 2.1 The "3D Structural" View
- **Concept:** Earthquakes are visualized not just as dots, but as 3D bars (polygons) extruded from the ground.
- **Height:** Corresponds to **Magnitude** (Tall = Powerful).
- **Color:** Corresponds to **Depth** (Darker = Deep, Brighter = Shallow).
- **Visual Impact:** Instantly conveys the scale and distribution of energy.

### 2.2 Significance Filter (Performance Strategy)
- **Logic:** By default, filter out "noise" (Magnitude < 4.5).
- **Control:** User can toggle "Show All" vs "Major Events Only".
- **Benefit:** Keeps the KML lightweight and the map uncluttered for high-impact demos.

### 2.3 Live Data Feed
- **Source:** USGS Earthquake Hazards Program (GeoJSON API).
- **Update Rate:** Poll every 60 seconds (user configurable).
- **Coverage:** Global, past 24 hours / 7 days.

### 2.4 Interactive Control
- **List View:** Scrollable list of recent significant quakes on the tablet.
- **Fly To:** Tapping an event rotates the Earth to center on that quake and zooms in.
- **Info Balloon:** Displays detailed stats (Mag, Location, Time, Depth) on the main screen.

## 3. Architecture (Device-Centric)

The app follows the existing **Clean Architecture** of the LG Flutter Starter Kit.

### 3.1 Data Flow
1.  **USGS API** provides JSON data.
2.  **App (Data Layer)** parses JSON into Entity objects.
3.  **App (Domain Layer)** filters and sorts entities (Significance Filter).
4.  **App (KML Service)** generates XML strings `<Placemark>` with `<Polygon>`.
5.  **App (SSH Service)** pushes KML to `/var/www/html/earthquakes.kml` on LG Master via SFTP.
6.  **LG Master** reads KML and renders 3D visualization.

### 3.2 Key Components

| Component | Responsibility |
|-----------|----------------|
| `EarthquakeRepository` | Fetches data from USGS, handles caching. |
| `KMLService` | specialized builder for generating 3D polygon KML. |
| `SSHService` | Handles SFTP upload and command execution (flyTo). |
| `HomeViewModel` | Manages state (loading, list of quakes, filter settings). |

## 4. Technical Specifications

### 4.1 Data Source
- **Endpoint:** `https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_day.geojson`
- **Format:** GeoJSON
- **Fields Needed:** `mag`, `place`, `time`, `url`, `detail`, `coordinates` (lat, lon, depth).

### 4.2 KML Structure (3D Bar)
```xml
<Placemark>
  <name>M 5.4 - Japan</name>
  <Polygon>
    <extrude>1</extrude>
    <altitudeMode>relativeToGround</altitudeMode>
    <outerBoundaryIs>
       <!-- 4 points forming a small square around the center -->
    </outerBoundaryIs>
  </Polygon>
  <Style>
     <!-- Color based on depth -->
  </Style>
</Placemark>
```

### 4.3 Security & Performance
- **Connection:** Secure SSH (as implemented).
- **Storage:** Sensitive data (passwords) in `FlutterSecureStorage`.
- **Optimization:** Use `StringBuffer` for KML generation to avoid memory thrashing.

## 5. Learning Objectives
- Working with external REST APIs (Dio/Http).
- Advanced string manipulation for KML generation.
- Understanding geospatial coordinates and polygon math.
- State management with complex lists and filters.
