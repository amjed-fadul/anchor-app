// Background service worker for Anchor extension
// Handles: Auth state, badge updates, background sync

console.log('Anchor background service worker loaded')

// Listen for extension install
chrome.runtime.onInstalled.addListener((details) => {
  if (details.reason === 'install') {
    console.log('Anchor extension installed!')

    // Set initial badge
    chrome.action.setBadgeBackgroundColor({ color: '#000000' })
    chrome.action.setBadgeText({ text: '' })
  }
})

// Listen for messages from popup/content scripts
chrome.runtime.onMessage.addListener((message, _sender, sendResponse) => {
  console.log('Background received message:', message)

  switch (message.type) {
    case 'GET_CURRENT_TAB':
      chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
        if (tabs[0]) {
          sendResponse({
            url: tabs[0].url,
            title: tabs[0].title,
            favIconUrl: tabs[0].favIconUrl,
          })
        }
      })
      return true // Keep message channel open for async response

    case 'UPDATE_BADGE':
      chrome.action.setBadgeText({ text: message.count.toString() })
      sendResponse({ success: true })
      break

    default:
      console.warn('Unknown message type:', message.type)
  }

  return false
})

// Export empty object to satisfy ES module requirements
export {}
