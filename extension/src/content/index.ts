// Content script for Anchor extension
// Runs on every webpage to extract metadata

console.log('Anchor content script loaded on:', window.location.href)

/**
 * Extract Open Graph metadata from the current page
 */
function extractMetadata() {
  const metadata = {
    url: window.location.href,
    title: document.title,
    description: '',
    thumbnail: '',
    domain: window.location.hostname,
  }

  // Try to get og:title
  const ogTitle = document.querySelector('meta[property="og:title"]')
  if (ogTitle) {
    metadata.title = ogTitle.getAttribute('content') || metadata.title
  }

  // Try to get og:description
  const ogDescription = document.querySelector('meta[property="og:description"]')
  if (ogDescription) {
    metadata.description = ogDescription.getAttribute('content') || ''
  } else {
    // Fallback to meta description
    const metaDescription = document.querySelector('meta[name="description"]')
    if (metaDescription) {
      metadata.description = metaDescription.getAttribute('content') || ''
    }
  }

  // Try to get og:image
  const ogImage = document.querySelector('meta[property="og:image"]')
  if (ogImage) {
    metadata.thumbnail = ogImage.getAttribute('content') || ''
  }

  return metadata
}

// Listen for messages from popup/background
chrome.runtime.onMessage.addListener((message, _sender, sendResponse) => {
  if (message.action === 'getMetadata') {
    const metadata = extractMetadata()
    sendResponse(metadata)
  }

  return false
})

// Export empty object to satisfy ES module requirements
export {}
