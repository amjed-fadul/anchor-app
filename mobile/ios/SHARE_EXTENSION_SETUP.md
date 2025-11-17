# iOS Share Extension Setup Instructions

## Step 1: Open Xcode

```bash
cd /Users/amjedfadul/Desktop/Anchor\ App/mobile/ios
open Runner.xcworkspace
```

## Step 2: Create Share Extension Target

1. In Xcode, click on the **Runner** project in the left sidebar (blue icon)
2. Click the **+** button at the bottom of the Targets list
3. Select **Share Extension** from the template chooser
4. Click **Next**

## Step 3: Configure Share Extension

Fill in the following:
- **Product Name:** `AnchorShareExtension`
- **Team:** Select your development team
- **Organization Name:** Same as main app
- **Organization Identifier:** `com.anchor.app` (or your bundle ID prefix)
- **Language:** Swift
- **Project:** Runner
- **Embed in Application:** Runner

Click **Finish**

## Step 4: Activate Scheme (when prompted)

When Xcode asks "Activate AnchorShareExtension scheme?", click **Activate**

## Step 5: Configure App Groups

### For Runner (Main App):
1. Select **Runner** target
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability** button
4. Search for and add **App Groups**
5. Click the **+** under App Groups
6. Enter: `group.com.anchor.app`
7. Check the checkbox next to it

### For AnchorShareExtension:
1. Select **AnchorShareExtension** target
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability** button
4. Search for and add **App Groups**
5. Click the **+** under App Groups
6. Enter: `group.com.anchor.app` (same as main app)
7. Check the checkbox next to it

## Step 6: Verify File Structure

After creating the extension, you should see a new folder:
```
ios/
├── Runner/
├── AnchorShareExtension/
│   ├── ShareViewController.swift
│   ├── Info.plist
│   └── AnchorShareExtension.entitlements
└── Runner.xcworkspace
```

## Step 7: Replace ShareViewController.swift

The file will be auto-generated, but we'll replace it with our custom implementation in the next step.

## Step 8: Add "anchor://" URL Scheme to Info.plist

We need to configure the main app to handle `anchor://share` deep links.

1. In Xcode, open **Runner/Info.plist**
2. Find the `CFBundleURLTypes` array (should already exist for Supabase deep links)
3. Add a new URL Type for Anchor deep links:

**Right-click on Info.plist → Open As → Source Code**, then add this inside the `<dict>` block under the existing `CFBundleURLTypes`:

```xml
<!-- Add this inside the <array> under CFBundleURLTypes -->
<dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLName</key>
    <string>com.anchor.app</string>
    <key>CFBundleURLSchemes</key>
    <array>
        <string>anchor</string>
    </array>
</dict>
```

This allows the main app to receive `anchor://share?url=...` deep links from the Share Extension.

## ✅ Checkpoint

After completing these steps:
- [ ] AnchorShareExtension target created
- [ ] App Groups capability added to both targets
- [ ] `group.com.anchor.app` configured and checked
- [ ] New AnchorShareExtension folder visible in Xcode
- [ ] `anchor://` URL scheme added to Runner/Info.plist

**Once done, return to this terminal and I'll create the Swift implementation files.**
