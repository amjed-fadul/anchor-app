# Share Extension Testing Guide

## 🎉 **Implementation Status**

✅ **Android**: Fully implemented and ready to test
⏳ **iOS**: Implementation files ready, requires Xcode configuration

---

## 🤖 **Android Testing (Ready Now!)**

### Prerequisites
- Flutter SDK installed
- Android device or emulator running
- Anchor app installed (`flutter run`)

### Step-by-Step Testing

#### 1. Build and Install
```bash
cd /Users/amjedfadul/Desktop/Anchor\ App/mobile
flutter run
```

#### 2. Test from Chrome
1. Open **Chrome** on your Android device/emulator
2. Navigate to any webpage (e.g., https://flutter.dev)
3. Tap the **⋮** (menu) button
4. Tap **Share**
5. Look for **"Anchor"** in the share sheet
6. Tap **"Anchor"**

**Expected Result:**
- ✅ Anchor app launches
- ✅ Loading screen appears ("Fetching metadata...")
- ✅ Success screen appears with gradient background
- ✅ Progress bar counts down (3 seconds)
- ✅ "Tap anywhere to close" hint displayed
- ✅ Screen auto-dismisses after 3 seconds
- ✅ Returns to Chrome
- ✅ Open Anchor app → Link is saved in home screen

#### 3. Test from Other Apps
Try sharing from:
- **Twitter/X**: Share a tweet link
- **Reddit**: Share a post link
- **Gmail**: Share a link from an email
- **YouTube**: Share a video link

#### 4. Test Edge Cases
- **Long URL**: Share a URL with many query parameters
- **URL Shortener**: Share a bit.ly or t.co link (should expand automatically)
- **Duplicate**: Share the same URL twice (should detect duplicate)
- **Offline**: Turn on airplane mode, share a link (should save offline)

### Debug Logs

To see detailed logs while testing:
```bash
# In a separate terminal
flutter logs | grep -E "ShareActivity|DEEP_LINK|AddLinkFlow|LinkSuccess"
```

**What to Look For:**
```
🔵 [ShareActivity] Received shared text: https://...
🟢 [ShareActivity] Extracted URL: https://...
🔵 [DEEP_LINK] Processing URI
🔵 [DEEP_LINK] ✅ Received shared URL: https://...
🔵 [AddLinkFlow] Handling shared URL: https://...
🔵 [LinkSuccess] Auto-closing after 3 seconds
```

### Common Issues & Solutions

#### Issue: "Anchor" doesn't appear in share sheet
**Solution:**
- Ensure app is installed (`flutter run`)
- Check AndroidManifest.xml has ShareActivity
- Restart device/emulator

#### Issue: App launches but shows URL input screen
**Solution:**
- Check deep link is being received: `flutter logs | grep DEEP_LINK`
- Ensure HomeScreen is checking for pending shares

#### Issue: Progress bar not showing
**Solution:**
- Verify `autoClose=true` is passed to LinkSuccessScreen
- Check AddLinkFlowScreen sets `_isSharedUrl` correctly

---

## 🍎 **iOS Testing (After Xcode Setup)**

### Prerequisites
- Xcode installed and opened
- Apple Developer account (free or paid)
- iOS Simulator or physical iPhone

### Setup Instructions
Follow the comprehensive guide at:
```
/Users/amjedfadul/Desktop/Anchor App/mobile/ios/SHARE_EXTENSION_SETUP.md
```

**Quick Summary:**
1. Open Xcode: `open ios/Runner.xcworkspace`
2. Create Share Extension target: "AnchorShareExtension"
3. Configure App Groups: `group.com.anchor.app`
4. Add `anchor://` URL scheme to Runner/Info.plist
5. Replace auto-generated files with prepared files in `ios/ShareExtensionFiles/`
6. Build and run

### Testing Steps (Same as Android)
1. Run app in iOS Simulator (Cmd+R in Xcode)
2. Open Safari
3. Navigate to https://flutter.dev
4. Tap Share button
5. Select "Anchor"
6. Verify same flow as Android

---

## 📊 **Test Checklist**

### Functional Tests
- [ ] Share from Chrome works
- [ ] Share from Safari works (iOS)
- [ ] Share from Twitter/X works
- [ ] "Anchor" appears in share sheet
- [ ] App launches when "Anchor" tapped
- [ ] Loading screen appears
- [ ] Success screen appears with gradient
- [ ] Progress bar counts down (3 seconds)
- [ ] "Tap anywhere to close" hint shows
- [ ] Auto-dismisses after 3 seconds
- [ ] Returns to previous app
- [ ] Link saved in home screen
- [ ] Metadata extracted (title, thumbnail)

### Edge Case Tests
- [ ] URL shortener expands (bit.ly, t.co)
- [ ] Duplicate detection works
- [ ] Offline save works (airplane mode)
- [ ] Long URLs work
- [ ] URLs with special characters work
- [ ] Multiple shares in quick succession

### Performance Tests
- [ ] Save completes in <1 second
- [ ] Metadata fetches in <5 seconds
- [ ] No memory leaks (profile in DevTools)
- [ ] No UI lag or jank

---

## 🐛 **Reporting Issues**

If you find issues, provide:
1. **Platform**: Android or iOS
2. **Source App**: Where you shared from (Chrome, Twitter, etc.)
3. **Expected**: What should have happened
4. **Actual**: What actually happened
5. **Logs**: Output from `flutter logs | grep -E "ShareActivity|DEEP_LINK"`

---

## ✅ **Success Criteria**

Share Extension is working correctly when:
1. ✅ "Anchor" appears in system share sheet on both platforms
2. ✅ Sharing from any app launches Anchor
3. ✅ Link saves in <1 second
4. ✅ Success screen shows and auto-dismisses
5. ✅ User can tap to dismiss early
6. ✅ Link appears in home screen with metadata
7. ✅ Works offline (saves to Hive)
8. ✅ Detects duplicates
9. ✅ Expands URL shorteners

---

**Ready to test? Run `flutter run` and start sharing links!** 🚀
