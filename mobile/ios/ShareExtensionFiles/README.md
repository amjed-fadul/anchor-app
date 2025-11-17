# Share Extension Files - Ready for Xcode

These files should be used to **replace** the auto-generated files in Xcode after creating the Share Extension target.

## Files in this directory:

1. **ShareViewController.swift** - Main share extension logic
2. **Info.plist** - Share extension configuration

## How to use these files:

### After completing the Xcode setup (from SHARE_EXTENSION_SETUP.md):

1. In Xcode, locate the **AnchorShareExtension** folder in the left sidebar
2. Select and delete the auto-generated `ShareViewController.swift`
3. Right-click on **AnchorShareExtension** folder → Add Files to "Runner"...
4. Navigate to this directory and select `ShareViewController.swift`
5. Make sure "Copy items if needed" is **unchecked**
6. Make sure "Add to targets" has **AnchorShareExtension** checked
7. Click **Add**

### For Info.plist:

1. In Xcode, select `AnchorShareExtension/Info.plist` in the left sidebar
2. Open the file from this directory in a text editor
3. Copy the entire contents
4. Paste into the Xcode Info.plist (you can right-click → Open As → Source Code)
5. Save

## ✅ What these files do:

### ShareViewController.swift:
- Extracts URL from share extension context
- Handles both direct URL shares and text containing URLs
- Opens main Anchor app with deep link: `anchor://share?url=...`
- Comprehensive error handling and logging
- Auto-closes after successful share

### Info.plist:
- Configures share extension to accept:
  - Web URLs (from Safari, Chrome, etc.)
  - Web pages
  - Text containing URLs (from Twitter, etc.)
- Sets display name to "Anchor"
- Configures proper bundle identifiers

## 🧪 Testing after setup:

1. Build and run the app on iOS simulator (Cmd+R)
2. Open Safari
3. Navigate to any webpage (e.g., https://flutter.dev)
4. Tap the Share button
5. Look for "Anchor" in the share sheet
6. Tap "Anchor"
7. Main app should launch with the shared URL

## 🐛 Debugging:

To see logs from the share extension:
1. In Xcode, select **AnchorShareExtension** scheme (next to Run button)
2. Run the extension (Cmd+R)
3. Choose Safari or another app to test with
4. Share a URL
5. Check Xcode console for logs starting with `[ShareExtension]`
