import { ExternalLink, Folder, Calendar, MoreVertical } from 'lucide-react'
import type { Link, Space } from '../lib/types'

interface LinkCardProps {
  link: Link
  space?: Space
  onClick?: () => void
  onMenuClick?: (e: React.MouseEvent) => void
}

export function LinkCard({ link, space, onClick, onMenuClick }: LinkCardProps) {
  const formattedDate = new Date(link.created_at).toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
  })

  return (
    <div
      className="group flex gap-3 p-3 hover:bg-gray-50 rounded-lg transition-colors cursor-pointer"
      onClick={onClick}
    >
      {/* Thumbnail */}
      <div className="flex-shrink-0">
        {link.thumbnail_url ? (
          <img
            src={link.thumbnail_url}
            alt=""
            className="w-16 h-16 rounded object-cover bg-gray-100"
            onError={(e) => {
              // Fallback to placeholder if image fails to load
              e.currentTarget.src = 'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" width="64" height="64"%3E%3Crect width="64" height="64" fill="%23f3f4f6"/%3E%3C/svg%3E'
            }}
          />
        ) : (
          <div className="w-16 h-16 rounded bg-gray-100 flex items-center justify-center">
            <ExternalLink className="w-6 h-6 text-gray-400" />
          </div>
        )}
      </div>

      {/* Content */}
      <div className="flex-1 min-w-0">
        {/* Title */}
        <h3 className="font-medium text-sm line-clamp-1 group-hover:text-black">
          {link.title}
        </h3>

        {/* Description or Note */}
        {(link.description || link.note) && (
          <p className="text-xs text-gray-600 line-clamp-2 mt-1">
            {link.note || link.description}
          </p>
        )}

        {/* Metadata */}
        <div className="flex items-center gap-3 mt-2 text-xs text-gray-500">
          {/* Space */}
          {space && (
            <div className="flex items-center gap-1">
              <Folder className="w-3 h-3" />
              <span>{space.name}</span>
            </div>
          )}

          {/* Domain */}
          <div className="flex items-center gap-1">
            <ExternalLink className="w-3 h-3" />
            <span>{link.domain}</span>
          </div>

          {/* Date */}
          <div className="flex items-center gap-1">
            <Calendar className="w-3 h-3" />
            <span>{formattedDate}</span>
          </div>
        </div>
      </div>

      {/* Menu button */}
      <button
        onClick={(e) => {
          e.stopPropagation()
          onMenuClick?.(e)
        }}
        className="flex-shrink-0 p-2 opacity-0 group-hover:opacity-100 hover:bg-gray-200 rounded transition-opacity"
      >
        <MoreVertical className="w-4 h-4 text-gray-600" />
      </button>
    </div>
  )
}
