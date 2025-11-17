# Quick Android Share Extension Test

## ✅ Pre-Test Verification Complete

All code verified and ready:
- ✅ ShareActivity.kt created (4211 bytes)
- ✅ AndroidManifest.xml configured with ACTION_SEND intent
- ✅ anchor://share deep link configured
- ✅ Flutter integration complete (DeepLinkService, AddLinkFlowScreen, HomeScreen)
- ✅ Auto-dismiss feature implemented (3-second countdown)
- ✅ No compilation errors (`flutter analyze` passed)

## 🚀 Testing Steps (5 minutes)

### Step 1: Build and Install (2 min)
```bash
cd "/Users/amjedfadul/Desktop/Anchor App/mobile"
flutter run -d R5CT90STTML
```

Wait for app to install on your **Samsung Galaxy S22**.

### Step 2: Test Share from Chrome (2 min)

1. Open **Chrome** on your Samsung S22
2. Navigate to: `https://flutter.dev`
3. Tap the **⋮** menu button (top right)
4. Tap **Share**
5. Look for **"Anchor"** in the share sheet
6. Tap **"Anchor"**

### Step 3: Expected Behavior (What You Should See)

**✅ Success Flow:**
1. Anchor app launches immediately
2. Loading screen appears: "Fetching metadata..."
3. Success screen appears with gradient (green → blue)
4. Large text: **"Anchored!"**
5. Subtitle: "Find it anytime"
6. **Progress bar at top** counting down (3 seconds)
7. Text: "Tap anywhere to close"
8. Screen auto-dismisses after 3 seconds
9. Returns to Chrome
10. Open Anchor app → Link saved in home screen

**❌ If Something Goes Wrong:**
- "Anchor" not in share sheet? → Check AndroidManifest.xml, rebuild
- App launches but shows URL input? → Check deep link logs (see below)
- Progress bar not showing? → Check autoClose parameter

### Step 4: Debug Logs (Run in Separate Terminal)

```bash
# Terminal 2:
flutter logs | grep -E "ShareActivity|DEEP_LINK|AddLinkFlow|LinkSuccess"
```

**What to Look For:**
```
🔵 [ShareActivity] Received shared text: https://flutter.dev
🟢 [ShareActivity] Extracted URL: https://flutter.dev
🔵 [DEEP_LINK] Processing URI: anchor://share?url=...
🔵 [DEEP_LINK] ✅ Received shared URL: https://flutter.dev
🔵 [AddLinkFlow] Handling shared URL: https://flutter.dev
🔵 [LinkSuccess] Auto-closing after 3 seconds
```

### Step 5: Test from Other Apps (Optional)

Try sharing from:
- **YouTube**: Share a video link
- **Twitter/X**: Share a tweet
- **Gmail**: Share a link from email

### Step 6: Test Edge Cases (Optional)

- **Long URL**: Share a URL with many query parameters
- **Duplicate**: Share the same URL twice (should detect)
- **Offline**: Turn on airplane mode, share link (should save offline)

## 🎉 Success Criteria

All checks should pass:
- [ ] "Anchor" appears in share sheet
- [ ] App launches when "Anchor" tapped
- [ ] Loading screen shows
- [ ] Success screen shows with gradient
- [ ] Progress bar counts down (3 seconds)
- [ ] Auto-dismisses after 3 seconds
- [ ] Link saved in home screen
- [ ] Metadata extracted (title, thumbnail)

## 🐛 Common Issues

**Issue: "Anchor" doesn't appear in share sheet**
- Solution: Uninstall old app, rebuild with `flutter run -d R5CT90STTML`

**Issue: App launches but shows URL input screen**
- Solution: Check logs with `flutter logs | grep DEEP_LINK`
- Verify HomeScreen is checking for pending shares

**Issue: Progress bar not showing**
- Solution: Verify `autoClose=true` in AddLinkFlowScreen:220

## ⏱️ Estimated Test Time: 5 minutes

Ready to test? Run:
```bash
flutter run -d R5CT90STTML
```

Then share a link from Chrome! 🚀
