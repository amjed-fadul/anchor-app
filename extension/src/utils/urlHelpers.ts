/**
 * URL Helper Utilities
 * 
 * Functions for URL manipulation, validation, and normalization
 * Based on mobile app's UrlValidator implementation
 */

/**
 * Normalize a URL by removing tracking parameters and standardizing format
 * 
 * - Removes tracking params (utm_*, fbclid, gclid, ref, etc.)
 * - Removes www. subdomain
 * - Removes trailing slash
 * - Converts to lowercase
 * - Removes fragment (#section)
 */
export function normalizeUrl(url: string): string {
    let normalized = url.trim();

    // Remove common tracking parameters
    normalized = normalized.replace(/[?&](utm_[^&]+|fbclid=[^&]+|gclid=[^&]+|ref=[^&]+|source=[^&]+)/g, '');

    // Remove www. subdomain
    normalized = normalized.replace(/^(https?:\/\/)www\./i, '$1');

    // Remove trailing slash
    normalized = normalized.replace(/\/$/, '');

    // Lowercase the entire URL for consistency
    normalized = normalized.toLowerCase();

    // Remove fragment (#section)
    normalized = normalized.replace(/#.*$/, '');

    // Clean up any leftover question marks or ampersands
    normalized = normalized.replace(/[?&]$/, '');

    return normalized;
}

/**
 * Extract domain from URL
 * 
 * Examples:
 * - https://www.example.com/path → example.com
 * - http://subdomain.example.co.uk → subdomain.example.co.uk
 */
export function extractDomain(url: string): string {
    try {
        const urlObj = new URL(url);
        // Remove www. if present
        return urlObj.hostname.replace(/^www\./, '');
    } catch (e) {
        // If URL parsing fails, try to extract domain manually
        const match = url.match(/^(?:https?:\/\/)?(?:www\.)?([^\/]+)/i);
        return match ? match[1] : url;
    }
}

/**
 * Validate URL format
 * 
 * Returns error message if invalid, null if valid
 */
export function validateUrl(url: string | null | undefined): string | null {
    if (!url || url.trim().length === 0) {
        return 'URL is required';
    }

    const trimmedUrl = url.trim();

    // Add protocol if missing for validation
    const urlToValidate = /^https?:\/\//i.test(trimmedUrl)
        ? trimmedUrl
        : `https://${trimmedUrl}`;

    // Use browser's built-in URL validation
    try {
        new URL(urlToValidate);
        return null; // Valid!
    } catch (e) {
        return 'Please enter a valid URL';
    }
}

/**
 * Ensure URL has protocol (http/https)
 * 
 * If URL doesn't start with http:// or https://, prepend https://
 */
export function ensureProtocol(url: string): string {
    const trimmed = url.trim();
    if (!/^https?:\/\//i.test(trimmed)) {
        return `https://${trimmed}`;
    }
    return trimmed;
}

/**
 * Get current active tab URL and title using Chrome Extension API
 */
export async function getCurrentTab(): Promise<{ url: string; title: string } | null> {
    try {
        const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
        if (tab && tab.url && tab.title) {
            return {
                url: tab.url,
                title: tab.title,
            };
        }
        return null;
    } catch (error) {
        console.error('Failed to get current tab:', error);
        return null;
    }
}
