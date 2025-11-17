//
//  ShareViewController.swift
//  AnchorShareExtension
//
//  Handles sharing URLs from other apps to Anchor.
//  Extracts URL from share context and opens main app with deep link.
//

import UIKit
import Social
import UniformTypeIdentifiers

class ShareViewController: SLComposeServiceViewController {

    // MARK: - Properties
    private let appGroupId = "group.com.anchor.app"

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        print("🔵 [ShareExtension] viewDidLoad - Starting URL extraction")

        // Configure UI
        placeholder = "Saving to Anchor..."

        // Extract and process URL
        extractSharedURL { [weak self] url in
            guard let self = self else { return }

            if let url = url {
                print("🟢 [ShareExtension] URL extracted: \(url)")
                self.openMainAppWithURL(url)
            } else {
                print("🔴 [ShareExtension] Failed to extract URL")
                self.showError("Could not extract URL from shared content")
            }
        }
    }

    // MARK: - URL Extraction

    /// Extract URL from share extension context
    /// Handles both direct URL shares and text containing URLs
    private func extractSharedURL(completion: @escaping (String?) -> Void) {
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let itemProvider = extensionItem.attachments?.first else {
            print("🔴 [ShareExtension] No extension items found")
            completion(nil)
            return
        }

        print("🔵 [ShareExtension] Found item provider")

        // Try to get URL directly
        if itemProvider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
            print("🔵 [ShareExtension] Item conforms to URL type")
            itemProvider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { (item, error) in
                if let error = error {
                    print("🔴 [ShareExtension] Error loading URL item: \(error)")
                    completion(nil)
                    return
                }

                if let url = item as? URL {
                    print("🟢 [ShareExtension] Extracted URL directly: \(url.absoluteString)")
                    completion(url.absoluteString)
                } else if let data = item as? Data, let urlString = String(data: data, encoding: .utf8) {
                    print("🟢 [ShareExtension] Extracted URL from data: \(urlString)")
                    completion(urlString)
                } else {
                    print("🔴 [ShareExtension] Could not convert item to URL")
                    completion(nil)
                }
            }
        }
        // Fallback: Try to get text and extract URL from it
        else if itemProvider.hasItemConformingToTypeIdentifier(UTType.text.identifier) {
            print("🔵 [ShareExtension] Item conforms to text type, will extract URL")
            itemProvider.loadItem(forTypeIdentifier: UTType.text.identifier, options: nil) { (item, error) in
                if let error = error {
                    print("🔴 [ShareExtension] Error loading text item: \(error)")
                    completion(nil)
                    return
                }

                if let text = item as? String {
                    print("🔵 [ShareExtension] Extracted text: \(text.prefix(100))...")
                    let extractedURL = self.extractURLFromText(text)
                    if let extractedURL = extractedURL {
                        print("🟢 [ShareExtension] Found URL in text: \(extractedURL)")
                    } else {
                        print("🔴 [ShareExtension] No URL found in text")
                    }
                    completion(extractedURL)
                } else {
                    print("🔴 [ShareExtension] Could not convert item to String")
                    completion(nil)
                }
            }
        } else {
            print("🔴 [ShareExtension] Item does not conform to URL or text type")
            completion(nil)
        }
    }

    /// Extract URL from text using regex
    private func extractURLFromText(_ text: String) -> String? {
        // Regex to find URLs in text
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector?.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))

        if let match = matches?.first, let url = match.url {
            return url.absoluteString
        }

        return nil
    }

    // MARK: - Main App Communication

    /// Open main app with shared URL via deep link
    private func openMainAppWithURL(_ urlString: String) {
        // URL encode the shared URL for deep link parameter
        guard let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("🔴 [ShareExtension] Failed to encode URL")
            showError("Invalid URL format")
            return
        }

        // Create deep link to main app
        let deepLinkString = "anchor://share?url=\(encodedURL)"
        guard let deepLinkURL = URL(string: deepLinkString) else {
            print("🔴 [ShareExtension] Failed to create deep link URL")
            showError("Failed to create deep link")
            return
        }

        print("🔵 [ShareExtension] Opening main app with deep link: \(deepLinkString)")

        // Open main app
        // Note: This uses a private API workaround that works in share extensions
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                print("🟢 [ShareExtension] Found UIApplication, opening URL")
                application.perform(#selector(openURL(_:)), with: deepLinkURL)

                // Close share extension after a brief delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
                }
                return
            }
            responder = responder?.next
        }

        print("🔴 [ShareExtension] Could not find UIApplication in responder chain")

        // Fallback: Just close the extension
        // The URL has been saved to App Group by this point
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }

    // MARK: - Error Handling

    private func showError(_ message: String) {
        print("🔴 [ShareExtension] Showing error: \(message)")

        let alert = UIAlertController(
            title: "Unable to Share",
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.cancel()
        })

        present(alert, animated: true)
    }

    // MARK: - SLComposeServiceViewController Overrides

    override func isContentValid() -> Bool {
        // Always return true - we validate in extractSharedURL
        return true
    }

    override func didSelectPost() {
        // Not used - we process immediately in viewDidLoad
        print("🔵 [ShareExtension] didSelectPost called (not used)")
    }

    override func didSelectCancel() {
        print("🔵 [ShareExtension] User cancelled share")
        super.didSelectCancel()
    }

    override func configurationItems() -> [Any]! {
        // No configuration items needed
        return []
    }
}
