/**
 * User-friendly error message mapping
 * Maps technical database/API errors to human-readable messages
 */

export interface FriendlyError {
    message: string;
    suggestion?: string;
    type: 'error' | 'warning' | 'info';
}

// Error patterns to match against error messages
const ERROR_PATTERNS: Array<{
    pattern: RegExp | string;
    error: FriendlyError;
}> = [
    // Duplicate URL - most common user error
    {
        pattern: /unique_user_normalized_url|duplicate key.*normalized_url/i,
        error: {
            message: "You've already saved this link",
            suggestion: "Search your links to find it",
            type: 'warning'
        }
    },
    {
        pattern: /23505/,  // PostgreSQL unique violation code
        error: {
            message: "This link already exists in your collection",
            suggestion: "Check your existing links",
            type: 'warning'
        }
    },

    // Authentication errors
    {
        pattern: /user must be authenticated/i,
        error: {
            message: "Your session has expired",
            suggestion: "Please sign in again to continue",
            type: 'error'
        }
    },
    {
        pattern: /invalid login credentials/i,
        error: {
            message: "Incorrect email or password",
            suggestion: "Check your credentials and try again",
            type: 'error'
        }
    },
    {
        pattern: /jwt expired|token.*expired/i,
        error: {
            message: "Your session has expired",
            suggestion: "Please sign in again",
            type: 'error'
        }
    },

    // Network errors
    {
        pattern: /failed to fetch|networkerror|network request failed/i,
        error: {
            message: "Unable to connect",
            suggestion: "Check your internet connection and try again",
            type: 'error'
        }
    },
    {
        pattern: /timeout|timed out/i,
        error: {
            message: "Request timed out",
            suggestion: "Please try again",
            type: 'error'
        }
    },
    {
        pattern: /offline|no internet/i,
        error: {
            message: "You're offline",
            suggestion: "Connect to the internet and try again",
            type: 'error'
        }
    },

    // Metadata fetch errors
    {
        pattern: /edge function error|failed to fetch metadata/i,
        error: {
            message: "Couldn't load page preview",
            suggestion: "Your link will be saved without a preview",
            type: 'warning'
        }
    },
    {
        pattern: /no data returned from edge function/i,
        error: {
            message: "Couldn't fetch page details",
            suggestion: "The link will be saved with basic info",
            type: 'warning'
        }
    },

    // Rate limiting
    {
        pattern: /rate limit|too many requests|429/i,
        error: {
            message: "Too many requests",
            suggestion: "Please wait a moment and try again",
            type: 'warning'
        }
    },

    // Permission errors
    {
        pattern: /permission denied|not authorized|403/i,
        error: {
            message: "Access denied",
            suggestion: "You don't have permission for this action",
            type: 'error'
        }
    },

    // URL validation
    {
        pattern: /url is required/i,
        error: {
            message: "Please enter a URL",
            suggestion: "Paste a link or use 'Current Tab'",
            type: 'error'
        }
    },
    {
        pattern: /invalid url|please enter a valid url/i,
        error: {
            message: "That doesn't look like a valid URL",
            suggestion: "Make sure the link starts with http:// or https://",
            type: 'error'
        }
    },

    // Server errors
    {
        pattern: /500|internal server error/i,
        error: {
            message: "Server error",
            suggestion: "Please try again in a moment",
            type: 'error'
        }
    },
    {
        pattern: /502|bad gateway/i,
        error: {
            message: "Service temporarily unavailable",
            suggestion: "Please try again in a few seconds",
            type: 'error'
        }
    },
];

/**
 * Convert a technical error to a user-friendly message
 */
export function getUserFriendlyError(error: unknown): FriendlyError {
    // Extract error message from various error formats
    let errorString = '';

    if (error instanceof Error) {
        errorString = error.message;
    } else if (typeof error === 'object' && error !== null) {
        const errObj = error as Record<string, unknown>;
        errorString = String(errObj.message || errObj.error || errObj.code || JSON.stringify(error));
    } else {
        errorString = String(error);
    }

    // Check against known patterns
    for (const { pattern, error: friendlyError } of ERROR_PATTERNS) {
        if (typeof pattern === 'string') {
            if (errorString.toLowerCase().includes(pattern.toLowerCase())) {
                return friendlyError;
            }
        } else if (pattern.test(errorString)) {
            return friendlyError;
        }
    }

    // Default fallback for unknown errors
    return {
        message: "Something went wrong",
        suggestion: "Please try again or contact support if the problem persists",
        type: 'error'
    };
}

/**
 * Check if an error is a duplicate URL error specifically
 */
export function isDuplicateUrlError(error: unknown): boolean {
    const errorString = error instanceof Error ? error.message : String(error);
    return /unique_user_normalized_url|duplicate key.*normalized_url|23505/i.test(errorString);
}

/**
 * Check if an error is an authentication error
 */
export function isAuthError(error: unknown): boolean {
    const errorString = error instanceof Error ? error.message : String(error);
    return /user must be authenticated|jwt expired|token.*expired|invalid login/i.test(errorString);
}

/**
 * Check if an error is a network error
 */
export function isNetworkError(error: unknown): boolean {
    const errorString = error instanceof Error ? error.message : String(error);
    return /failed to fetch|networkerror|timeout|offline/i.test(errorString);
}
