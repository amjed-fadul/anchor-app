import { useState, useEffect, useMemo } from 'react'
import { Search, Loader2, Clock, List, LayoutGrid } from 'lucide-react'
import { getRecentLinks, getSpaces } from '../lib/api'
import { LinkCard } from './LinkCard'
import type { Link, Space } from '../lib/types'

interface BrowseModeProps {
  userId: string
  selectedView: string
  searchQuery?: string
  onSearchChange?: (query: string) => void
}

export function BrowseMode({
  userId,
  selectedView,
  searchQuery = '',
  onSearchChange,
}: BrowseModeProps) {
  const [links, setLinks] = useState<Link[]>([])
  const [spaces, setSpaces] = useState<Space[]>([])
  const [loading, setLoading] = useState(true)
  const [localSearch, setLocalSearch] = useState(searchQuery)

  // Load links and spaces
  useEffect(() => {
    loadData()
  }, [userId, selectedView])

  async function loadData() {
    try {
      setLoading(true)

      const [linksData, spacesData] = await Promise.all([
        getRecentLinks(userId, 100), // Load more links for browsing
        getSpaces(userId),
      ])

      setLinks(linksData)
      setSpaces(spacesData)
    } catch (error) {
      console.error('Error loading data:', error)
    } finally {
      setLoading(false)
    }
  }

  // Filter links based on selected view and search query
  const filteredLinks = useMemo(() => {
    let result = links

    // Filter by view
    if (selectedView === 'all') {
      // Show all links
    } else if (selectedView === 'unsorted') {
      // Show links without space
      result = result.filter((link) => !link.space_id)
    } else if (selectedView === 'trash') {
      // TODO: Implement trash functionality
      result = []
    } else {
      // Filter by space ID
      result = result.filter((link) => link.space_id === selectedView)
    }

    // Filter by search query
    if (localSearch.trim()) {
      const query = localSearch.toLowerCase()
      result = result.filter(
        (link) =>
          link.title.toLowerCase().includes(query) ||
          link.url.toLowerCase().includes(query) ||
          link.domain.toLowerCase().includes(query) ||
          link.note?.toLowerCase().includes(query) ||
          link.description?.toLowerCase().includes(query)
      )
    }

    return result
  }, [links, selectedView, localSearch])

  // Get space for link
  function getSpaceForLink(link: Link): Space | undefined {
    if (!link.space_id) return undefined
    return spaces.find((s) => s.id === link.space_id)
  }

  // Get view title
  function getViewTitle(): string {
    if (selectedView === 'all') return 'All bookmarks'
    if (selectedView === 'unsorted') return 'Unsorted'
    if (selectedView === 'trash') return 'Trash'

    const space = spaces.find((s) => s.id === selectedView)
    return space?.name || 'Links'
  }

  // Handle search input
  function handleSearchChange(value: string) {
    setLocalSearch(value)
    onSearchChange?.(value)
  }

  // Handle link click
  function handleLinkClick(link: Link) {
    // Open link in new tab
    chrome.tabs.create({ url: link.url })

    // TODO: Update opened_at timestamp
  }

  return (
    <div className="flex-1 flex flex-col">
      {/* Header with Search */}
      <div className="p-4 border-b border-gray-200 space-y-3">
        {/* Search Bar */}
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
          <input
            type="text"
            value={localSearch}
            onChange={(e) => handleSearchChange(e.target.value)}
            placeholder="Search links..."
            className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-black focus:border-transparent"
          />
        </div>

        {/* View Title and Options */}
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <h2 className="text-lg font-semibold">{getViewTitle()}</h2>
            <span className="text-sm text-gray-500">
              {filteredLinks.length} {filteredLinks.length === 1 ? 'link' : 'links'}
            </span>
          </div>

          {/* View Options (TODO: Implement grid/list toggle) */}
          <div className="flex items-center gap-1">
            <button
              className="p-2 hover:bg-gray-100 rounded transition-colors"
              title="Recent"
            >
              <Clock className="w-4 h-4" />
            </button>
            <button
              className="p-2 hover:bg-gray-100 rounded transition-colors"
              title="List view"
            >
              <List className="w-4 h-4" />
            </button>
            <button
              className="p-2 hover:bg-gray-100 rounded transition-colors opacity-50"
              title="Grid view (coming soon)"
              disabled
            >
              <LayoutGrid className="w-4 h-4" />
            </button>
          </div>
        </div>
      </div>

      {/* Links List */}
      <div className="flex-1 overflow-y-auto">
        {loading ? (
          <div className="flex items-center justify-center h-full">
            <div className="flex flex-col items-center gap-3">
              <Loader2 className="w-8 h-8 animate-spin text-gray-400" />
              <p className="text-sm text-gray-600">Loading links...</p>
            </div>
          </div>
        ) : filteredLinks.length === 0 ? (
          <div className="flex items-center justify-center h-full">
            <div className="text-center space-y-2">
              <p className="text-sm text-gray-600">
                {localSearch.trim()
                  ? 'No links found matching your search'
                  : selectedView === 'unsorted'
                  ? 'No unsorted links'
                  : selectedView === 'trash'
                  ? 'Trash is empty'
                  : 'No links saved yet'}
              </p>
              <p className="text-xs text-gray-500">
                {!localSearch.trim() && selectedView !== 'trash' && (
                  'Click the + button to save your first link'
                )}
              </p>
            </div>
          </div>
        ) : (
          <div className="divide-y divide-gray-100">
            {filteredLinks.map((link) => (
              <LinkCard
                key={link.id}
                link={link}
                space={getSpaceForLink(link)}
                onClick={() => handleLinkClick(link)}
                onMenuClick={(_e) => {
                  console.log('Menu clicked for link:', link.id)
                  // TODO: Show context menu
                }}
              />
            ))}
          </div>
        )}
      </div>

      {/* Footer with count */}
      <div className="p-3 border-t border-gray-200 text-center text-xs text-gray-500">
        {filteredLinks.length > 0 && `${filteredLinks.length} bookmarks`}
      </div>
    </div>
  )
}
