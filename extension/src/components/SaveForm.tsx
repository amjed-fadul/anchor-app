import { useState, useEffect } from 'react'
import { Bookmark, Loader2, Hash, FileText, FolderOpen } from 'lucide-react'
import { saveLink, getSpaces, getTags, getUnreadSpace } from '../lib/api'
import { Toast, type ToastType } from './Toast'
import type { Space, Tag, PageMetadata } from '../lib/types'

interface SaveFormProps {
  userId: string
  onSaved?: () => void
}

export function SaveForm({ userId, onSaved }: SaveFormProps) {
  // Page metadata
  const [pageData, setPageData] = useState<PageMetadata | null>(null)
  const [loadingMetadata, setLoadingMetadata] = useState(true)

  // Form state
  const [selectedSpaceId, setSelectedSpaceId] = useState<string | null>(null)
  const [tagInput, setTagInput] = useState('')
  const [selectedTags, setSelectedTags] = useState<string[]>([])
  const [note, setNote] = useState('')

  // Data from Supabase
  const [spaces, setSpaces] = useState<Space[]>([])
  const [availableTags, setAvailableTags] = useState<Tag[]>([])

  // UI state
  const [saving, setSaving] = useState(false)
  const [toast, setToast] = useState<{
    message: string
    type: ToastType
  } | null>(null)

  // Load current page data and Supabase data on mount
  useEffect(() => {
    loadPageData()
    loadSpaces()
    loadTags()
  }, [])

  async function loadPageData() {
    try {
      setLoadingMetadata(true)

      // Get current tab info from background script
      const response = await chrome.runtime.sendMessage({
        type: 'GET_CURRENT_TAB',
      })

      if (!response) {
        throw new Error('Could not get current tab')
      }

      // Get metadata from content script
      const [tab] = await chrome.tabs.query({
        active: true,
        currentWindow: true,
      })

      if (!tab.id) {
        throw new Error('No active tab')
      }

      let metadata: PageMetadata = {
        url: response.url || '',
        title: response.title || 'Untitled',
        description: '',
        thumbnail: '',
        domain: new URL(response.url).hostname,
      }

      // Try to get Open Graph metadata from content script
      try {
        const ogData = await chrome.tabs.sendMessage(tab.id, {
          action: 'getMetadata',
        })

        if (ogData) {
          metadata = { ...metadata, ...ogData }
        }
      } catch (error) {
        console.warn('Could not get OG metadata:', error)
        // Continue with basic metadata
      }

      setPageData(metadata)
    } catch (error) {
      console.error('Error loading page data:', error)
      setToast({
        message: 'Could not load current page data',
        type: 'error',
      })
    } finally {
      setLoadingMetadata(false)
    }
  }

  async function loadSpaces() {
    try {
      const userSpaces = await getSpaces(userId)
      setSpaces(userSpaces)

      // Set default space to "Unread"
      const unreadSpace = await getUnreadSpace(userId)
      if (unreadSpace) {
        setSelectedSpaceId(unreadSpace.id)
      } else if (userSpaces.length > 0) {
        setSelectedSpaceId(userSpaces[0].id)
      }
    } catch (error) {
      console.error('Error loading spaces:', error)
    }
  }

  async function loadTags() {
    try {
      const userTags = await getTags(userId)
      setAvailableTags(userTags)
    } catch (error) {
      console.error('Error loading tags:', error)
    }
  }

  function handleTagInputKeyDown(e: React.KeyboardEvent) {
    if (e.key === 'Enter' || e.key === ',') {
      e.preventDefault()
      addTag()
    } else if (e.key === 'Backspace' && tagInput === '' && selectedTags.length > 0) {
      // Remove last tag if backspace on empty input
      removeTag(selectedTags[selectedTags.length - 1])
    }
  }

  function addTag() {
    const trimmed = tagInput.trim().toLowerCase()
    if (trimmed && !selectedTags.includes(trimmed)) {
      setSelectedTags([...selectedTags, trimmed])
      setTagInput('')
    }
  }

  function removeTag(tag: string) {
    setSelectedTags(selectedTags.filter((t) => t !== tag))
  }

  function selectSuggestedTag(tag: Tag) {
    if (!selectedTags.includes(tag.name)) {
      setSelectedTags([...selectedTags, tag.name])
    }
  }

  async function handleSave() {
    if (!pageData) return

    try {
      setSaving(true)

      await saveLink({
        userId,
        url: pageData.url,
        title: pageData.title,
        description: pageData.description || undefined,
        thumbnailUrl: pageData.thumbnail || undefined,
        spaceId: selectedSpaceId,
        note: note.trim() || undefined,
        tags: selectedTags,
      })

      // Show success toast
      setToast({
        message: 'Link saved successfully!',
        type: 'success',
      })

      // Reset form
      setNote('')
      setSelectedTags([])
      setTagInput('')

      // Reload page data for next save
      setTimeout(() => {
        loadPageData()
      }, 1000)

      onSaved?.()
    } catch (error: any) {
      console.error('Error saving link:', error)
      setToast({
        message: error.message || 'Failed to save link',
        type: 'error',
      })
    } finally {
      setSaving(false)
    }
  }

  // Filter available tags based on input
  const filteredTags = availableTags.filter(
    (tag) =>
      tag.name.includes(tagInput.toLowerCase()) &&
      !selectedTags.includes(tag.name)
  )

  if (loadingMetadata) {
    return (
      <div className="flex-1 flex items-center justify-center">
        <div className="flex flex-col items-center gap-3">
          <Loader2 className="w-8 h-8 animate-spin text-gray-400" />
          <p className="text-sm text-gray-600">Loading page...</p>
        </div>
      </div>
    )
  }

  if (!pageData) {
    return (
      <div className="flex-1 flex items-center justify-center p-4">
        <p className="text-sm text-red-600">Could not load current page</p>
      </div>
    )
  }

  return (
    <>
      {/* Toast */}
      {toast && (
        <Toast
          message={toast.message}
          type={toast.type}
          onClose={() => setToast(null)}
        />
      )}

      {/* Scrollable Form */}
      <div className="p-4 space-y-4">
        {/* Page Preview */}
        <div className="space-y-2">
          <h3 className="text-sm font-medium text-gray-600">Saving:</h3>
          <div className="p-3 bg-gray-50 rounded-lg space-y-1">
            <p className="font-medium text-sm line-clamp-2">{pageData.title}</p>
            <p className="text-xs text-gray-600 line-clamp-1">{pageData.domain}</p>
          </div>
        </div>

        {/* Space Selector */}
        <div className="space-y-2">
          <label className="flex items-center gap-2 text-sm font-medium">
            <FolderOpen className="w-4 h-4" />
            Space
          </label>
          <select
            value={selectedSpaceId || ''}
            onChange={(e) => setSelectedSpaceId(e.target.value || null)}
            className="input"
            disabled={saving}
          >
            {spaces.length === 0 && (
              <option value="">No spaces available</option>
            )}
            {spaces.map((space) => (
              <option key={space.id} value={space.id}>
                {space.name}
              </option>
            ))}
          </select>
        </div>

        {/* Tags Input */}
        <div className="space-y-2">
          <label className="flex items-center gap-2 text-sm font-medium">
            <Hash className="w-4 h-4" />
            Tags
          </label>

          {/* Selected Tags */}
          {selectedTags.length > 0 && (
            <div className="flex flex-wrap gap-2">
              {selectedTags.map((tag) => (
                <span
                  key={tag}
                  className="inline-flex items-center gap-1 px-2 py-1 bg-gray-100 text-sm rounded"
                >
                  #{tag}
                  <button
                    type="button"
                    onClick={() => removeTag(tag)}
                    className="text-gray-600 hover:text-black"
                    disabled={saving}
                  >
                    ×
                  </button>
                </span>
              ))}
            </div>
          )}

          {/* Tag Input */}
          <input
            type="text"
            value={tagInput}
            onChange={(e) => setTagInput(e.target.value)}
            onKeyDown={handleTagInputKeyDown}
            onBlur={addTag}
            placeholder="Type and press Enter..."
            className="input text-sm"
            disabled={saving}
          />

          {/* Tag Suggestions */}
          {tagInput && filteredTags.length > 0 && (
            <div className="border border-gray-200 rounded-lg overflow-hidden max-h-32 overflow-y-auto">
              {filteredTags.slice(0, 5).map((tag) => (
                <button
                  key={tag.id}
                  type="button"
                  onClick={() => selectSuggestedTag(tag)}
                  className="w-full px-3 py-2 text-left text-sm hover:bg-gray-100 flex items-center justify-between"
                  disabled={saving}
                >
                  <span>#{tag.name}</span>
                  <span className="text-xs text-gray-500">
                    {tag.usage_count} uses
                  </span>
                </button>
              ))}
            </div>
          )}
        </div>

        {/* Note */}
        <div className="space-y-2">
          <label className="flex items-center gap-2 text-sm font-medium">
            <FileText className="w-4 h-4" />
            Note <span className="text-gray-400 font-normal">(optional)</span>
          </label>
          <textarea
            value={note}
            onChange={(e) => setNote(e.target.value.slice(0, 200))}
            placeholder="Add a note..."
            maxLength={200}
            rows={3}
            className="input resize-none text-sm"
            disabled={saving}
          />
          <p className="text-xs text-gray-500 text-right">
            {note.length}/200
          </p>
        </div>

        {/* Save Button */}
        <div className="pt-4">
          <button
            onClick={handleSave}
            disabled={saving || !selectedSpaceId}
            className="btn-primary w-full flex items-center justify-center gap-2"
          >
            {saving ? (
              <>
                <Loader2 className="w-5 h-5 animate-spin" />
                Saving...
              </>
            ) : (
              <>
                <Bookmark className="w-5 h-5" />
                Save Link
              </>
            )}
          </button>
        </div>
      </div>
    </>
  )
}
