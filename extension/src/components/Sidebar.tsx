import { Bookmark, FolderOpen, Trash, Plus, ChevronDown } from 'lucide-react'
import type { Space } from '../lib/types'
import { SPACE_COLORS } from '../lib/types'

interface SidebarProps {
  userEmail: string
  spaces: Space[]
  selectedView: 'all' | 'unsorted' | 'trash' | string // string for space IDs
  onViewChange: (view: string) => void
  onAddLink: () => void
  onSignOut: () => void
  linkCounts: Record<string, number>
}

export function Sidebar({
  userEmail,
  spaces,
  selectedView,
  onViewChange,
  onAddLink,
  onSignOut,
  linkCounts,
}: SidebarProps) {
  const username = userEmail.split('@')[0]

  return (
    <div className="w-64 border-r border-gray-200 flex flex-col bg-gray-50">
      {/* User Profile */}
      <div className="p-4 border-b border-gray-200 bg-white">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2 flex-1 min-w-0">
            <div className="w-8 h-8 rounded-full bg-black text-white flex items-center justify-center text-sm font-medium">
              {username[0].toUpperCase()}
            </div>
            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-1">
                <span className="text-sm font-medium truncate">{username}</span>
                <button
                  onClick={onSignOut}
                  className="p-0.5 hover:bg-gray-100 rounded"
                  title="Sign out"
                >
                  <ChevronDown className="w-3 h-3 text-gray-600" />
                </button>
              </div>
            </div>
          </div>

          {/* Add Link Button */}
          <button
            onClick={onAddLink}
            className="p-1.5 hover:bg-gray-100 rounded transition-colors"
            title="Add link"
          >
            <Plus className="w-5 h-5" />
          </button>
        </div>
      </div>

      {/* Navigation */}
      <div className="flex-1 overflow-y-auto py-4">
        {/* All Links */}
        <button
          onClick={() => onViewChange('all')}
          className={`w-full flex items-center justify-between px-4 py-2 text-sm transition-colors ${
            selectedView === 'all'
              ? 'bg-gray-200 font-medium'
              : 'hover:bg-gray-100'
          }`}
        >
          <div className="flex items-center gap-2">
            <Bookmark className="w-4 h-4" />
            <span>All bookmarks</span>
          </div>
          <span className="text-xs text-gray-600">
            {linkCounts.all || 0}
          </span>
        </button>

        {/* Unsorted */}
        <button
          onClick={() => onViewChange('unsorted')}
          className={`w-full flex items-center justify-between px-4 py-2 text-sm transition-colors ${
            selectedView === 'unsorted'
              ? 'bg-gray-200 font-medium'
              : 'hover:bg-gray-100'
          }`}
        >
          <div className="flex items-center gap-2">
            <FolderOpen className="w-4 h-4" />
            <span>Unsorted</span>
          </div>
          <span className="text-xs text-gray-600">
            {linkCounts.unsorted || 0}
          </span>
        </button>

        {/* Trash */}
        <button
          onClick={() => onViewChange('trash')}
          className={`w-full flex items-center justify-between px-4 py-2 text-sm transition-colors ${
            selectedView === 'trash'
              ? 'bg-gray-200 font-medium'
              : 'hover:bg-gray-100'
          }`}
        >
          <div className="flex items-center gap-2">
            <Trash className="w-4 h-4" />
            <span>Trash</span>
          </div>
          <span className="text-xs text-gray-600">
            {linkCounts.trash || 0}
          </span>
        </button>

        {/* Spaces */}
        <div className="mt-4">
          <div className="px-4 py-2 text-xs font-medium text-gray-500 uppercase">
            Spaces
          </div>
          {spaces.map((space) => (
            <button
              key={space.id}
              onClick={() => onViewChange(space.id)}
              className={`w-full flex items-center justify-between px-4 py-2 text-sm transition-colors ${
                selectedView === space.id
                  ? 'bg-gray-200 font-medium'
                  : 'hover:bg-gray-100'
              }`}
            >
              <div className="flex items-center gap-2">
                <div
                  className="w-3 h-3 rounded"
                  style={{
                    backgroundColor:
                      SPACE_COLORS[space.color as keyof typeof SPACE_COLORS] ||
                      '#9ca3af',
                  }}
                />
                <span>{space.name}</span>
              </div>
              <span className="text-xs text-gray-600">
                {linkCounts[space.id] || 0}
              </span>
            </button>
          ))}
        </div>
      </div>
    </div>
  )
}
