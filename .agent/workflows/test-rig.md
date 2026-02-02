---
description: How to test a Flutter LG Controller with the Liquid Galaxy rig (real or simulated).
---

# Testing with Liquid Galaxy Rig

## Prerequisites

1. **LG Rig Access**: You need either:
   - A real Liquid Galaxy rig with SSH access
   - A virtual LG setup (VM with Google Earth)

2. **Connection Credentials**: Have ready:
   - LG Master IP address
   - SSH username (usually `lg`)
   - SSH password
   - Port (default: 22)

## 1. Configure Connection in App

Launch the Flutter app and navigate to **Settings** → **LG Connection**.

Enter:
- IP Address: `<your_lg_master_ip>`
- Port: `22`
- Username: `lg`
- Password: `<your_password>`

Tap **Save** (credentials are stored securely).

## 2. Test Connection

Tap **Connect** button. You should see:
- ✅ "Connected" status in the app
- Console output (if debugging): `SSH connection established`

## 3. Test Basic Commands

### FlyTo Test
1. Use the map or enter coordinates
2. Tap "FlyTo" button
3. **Verify**: Google Earth on LG screens should fly to the location

### Orbit Test
1. Select a location
2. Tap "Orbit" button
3. **Verify**: Google Earth should start orbiting around the point

### Relaunch Test
1. Go to Settings → LG Actions
2. Tap "Relaunch Google Earth"
3. **Verify**: All LG screens should restart and reload Google Earth

## 4. Test KML (if applicable)

1. Upload a KML file through the app
2. **Verify**: The KML visualization appears on the LG screens

## 5. Disconnect

1. Tap **Disconnect** in the app
2. **Verify**: Status shows "Disconnected"
3. **Verify**: No zombie SSH sessions on the rig (`ps aux | grep ssh`)

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Connection refused" | Check IP address and ensure SSH is enabled on LG |
| "Authentication failed" | Verify username and password |
| Commands not working | Check `/tmp/query.txt` on LG Master for errors |
| App crashes on connect | Check `flutter analyze` for issues |

## Simulated Testing (No Rig)

If you don't have access to a real rig:

1. Create a mock `LgService` that logs commands instead of executing SSH
2. Use `flutter test` with mocked providers
3. Verify UI flow works correctly before testing on real rig
