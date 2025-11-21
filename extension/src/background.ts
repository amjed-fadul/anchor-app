// Background service worker
console.log('Anchor extension background script loaded');

chrome.runtime.onInstalled.addListener(() => {
    console.log('Anchor extension installed');
});
