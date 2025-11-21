import { useState, useEffect } from 'react'
import { Auth } from './components/Auth'
import { Sidebar } from './components/Sidebar'
import { BrowseMode } from './components/BrowseMode'
import { SaveForm } from './components/SaveForm'
import { Modal } from './components/Modal'
import { getSession, getUser, signOut } from './lib/supabase'
import { getSpaces, getRecentLinks } from './lib/api'
import type { User } from '@supabase/supabase-js'
import type { Space } from './lib/types'
import { Anchor } from 'lucide-react'

function App() {
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)

  // View state
  const [selectedView, setSelectedView] = useState<string>('all')
  const [searchQuery, setSearchQuery] = useState('')

  // Modal state
  const [showSaveModal, setShowSaveModal] = useState(false)

  // Data state
  const [spaces, setSpaces] = useState<Space[]>([])
  const [linkCounts, setLinkCounts] = useState<Record<string, number>>({})

  // Check for existing session on mount
  useEffect(() => {
    checkSession()
  }, [])

  // Load spaces and link counts when user is authenticated
  useEffect(() => {
    if (user) {
      loadSpacesAndCounts()
    }
  }, [user])

  async function checkSession() {
    try {
      const session = await getSession()
      if (session) {
        const currentUser = await getUser()
        setUser(currentUser)
      }
    } catch (error) {
      console.error('Error checking session:', error)
    } finally {
      setLoading(false)
    }
  }

  async function loadSpacesAndCounts() {
    if (!user) return

    try {
      const [spacesData, linksData] = await Promise.all([
        getSpaces(user.id),
        getRecentLinks(user.id, 100),
      ])

      setSpaces(spacesData)

      // Calculate link counts
      const counts: Record<string, number> = {
        all: linksData.length,
        unsorted: linksData.filter((link) => !link.space_id).length,
        trash: 0, // TODO: Implement trash
      }

      // Count per space
      spacesData.forEach((space) => {
        counts[space.id] = linksData.filter(
          (link) => link.space_id === space.id
        ).length
      })

      setLinkCounts(counts)
    } catch (error) {
      console.error('Error loading spaces and counts:', error)
    }
  }

  async function handleSignOut() {
    try {
      await signOut()
      setUser(null)
      setSpaces([])
      setLinkCounts({})
      setSelectedView('all')
    } catch (error) {
      console.error('Error signing out:', error)
    }
  }

  function handleSaveSuccess() {
    // Reload data after saving
    loadSpacesAndCounts()
    // Close modal
    setShowSaveModal(false)
  }

  // Show loading state
  if (loading) {
    return (
      <div className="w-full h-full flex items-center justify-center bg-white">
        <div className="flex flex-col items-center gap-3">
          <Anchor className="w-8 h-8 animate-pulse" />
          <p className="text-sm text-gray-600">Loading...</p>
        </div>
      </div>
    )
  }

  // Show auth screen if not logged in
  if (!user) {
    return <Auth onAuthSuccess={checkSession} />
  }

  // Show main app UI with new layout
  return (
    <div className="w-full h-full flex bg-white">
      {/* Sidebar */}
      <Sidebar
        userEmail={user.email || ''}
        spaces={spaces}
        selectedView={selectedView}
        onViewChange={setSelectedView}
        onAddLink={() => setShowSaveModal(true)}
        onSignOut={handleSignOut}
        linkCounts={linkCounts}
      />

      {/* Main Content Area */}
      <BrowseMode
        userId={user.id}
        selectedView={selectedView}
        searchQuery={searchQuery}
        onSearchChange={setSearchQuery}
      />

      {/* Save Link Modal */}
      <Modal
        isOpen={showSaveModal}
        onClose={() => setShowSaveModal(false)}
        title="Save Link"
      >
        <SaveForm userId={user.id} onSaved={handleSaveSuccess} />
      </Modal>
    </div>
  )
}

export default App
