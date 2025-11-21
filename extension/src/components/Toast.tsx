import { useEffect } from 'react'
import { CheckCircle, XCircle, X } from 'lucide-react'

export type ToastType = 'success' | 'error'

interface ToastProps {
  message: string
  type: ToastType
  onClose: () => void
  duration?: number
}

export function Toast({ message, type, onClose, duration = 3000 }: ToastProps) {
  useEffect(() => {
    const timer = setTimeout(onClose, duration)
    return () => clearTimeout(timer)
  }, [duration, onClose])

  return (
    <div
      className={`fixed top-4 right-4 z-50 flex items-start gap-3 p-4 rounded-lg shadow-lg max-w-sm animate-slide-in ${
        type === 'success'
          ? 'bg-green-50 border border-green-200'
          : 'bg-red-50 border border-red-200'
      }`}
    >
      {/* Icon */}
      {type === 'success' ? (
        <CheckCircle className="w-5 h-5 text-green-600 flex-shrink-0 mt-0.5" />
      ) : (
        <XCircle className="w-5 h-5 text-red-600 flex-shrink-0 mt-0.5" />
      )}

      {/* Message */}
      <p
        className={`flex-1 text-sm font-medium ${
          type === 'success' ? 'text-green-800' : 'text-red-800'
        }`}
      >
        {message}
      </p>

      {/* Close button */}
      <button
        onClick={onClose}
        className={`p-1 rounded hover:bg-opacity-50 transition-colors ${
          type === 'success' ? 'hover:bg-green-100' : 'hover:bg-red-100'
        }`}
      >
        <X className="w-4 h-4 text-gray-600" />
      </button>
    </div>
  )
}
