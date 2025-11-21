import React, { useEffect, useState } from 'react';
import { Search, Plus, Filter, Loader2 } from 'lucide-react';
import LinkCard from '../components/LinkCard';
import AddLinkModal from '../components/AddLinkModal';
import { db } from '../lib/db';
import type { Link } from '../lib/db';

interface MainContentProps {
    activeTab: string;
}

const MainContent: React.FC<MainContentProps> = ({ activeTab }) => {
    const [links, setLinks] = useState<Link[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);
    const [spaces, setSpaces] = useState<any[]>([]);
    const [showAddLinkModal, setShowAddLinkModal] = useState(false);

    useEffect(() => {
        loadSpaces();
    }, []);

    useEffect(() => {
        loadLinks();
    }, [activeTab]);

    const loadSpaces = async () => {
        try {
            const fetchedSpaces = await db.getSpaces();
            setSpaces(fetchedSpaces);
        } catch (err) {
            console.error('Failed to load spaces:', err);
        }
    };

    const loadLinks = async () => {
        setLoading(true);
        setError(null);

        try {
            let fetchedLinks: Link[];

            if (activeTab === 'all') {
                fetchedLinks = await db.getLinks();
            } else if (activeTab === 'unsorted') {
                fetchedLinks = await db.getLinks(null); // null space_id = unsorted
            } else if (activeTab.startsWith('space:')) {
                // Extract space ID from "space:uuid" format
                const spaceId = activeTab.replace('space:', '');
                fetchedLinks = await db.getLinks(spaceId);
            } else {
                // Fallback to all links
                fetchedLinks = await db.getLinks();
            }

            setLinks(fetchedLinks);
        } catch (err: any) {
            console.error('Failed to load links:', err);
            setError(err.message || 'Failed to load links');
        } finally {
            setLoading(false);
        }
    };

    // Get the display title for the current view
    const getDisplayTitle = () => {
        if (activeTab === 'all') return 'All Links';
        if (activeTab === 'unsorted') return 'Unsorted';
        if (activeTab.startsWith('space:')) {
            const spaceId = activeTab.replace('space:', '');
            const space = spaces.find(s => s.id === spaceId);
            return space?.name || 'Space';
        }
        return activeTab;
    };

    const handleLinkAdded = () => {
        // Refresh links after adding a new one
        loadLinks();
    };

    return (
        <div className="flex-1 flex flex-col h-full bg-white">
            {/* Header */}
            <div className="h-16 border-b border-anchor-silver flex items-center justify-between px-6 bg-white sticky top-0 z-10">
                <div className="flex-1 max-w-md relative">
                    <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-anchor-slateText" size={18} />
                    <input
                        type="text"
                        placeholder="Search your anchors..."
                        className="w-full pl-10 pr-4 py-2 bg-anchor-ash border-none rounded-lg text-sm focus:ring-2 focus:ring-anchor-teal focus:outline-none text-anchor-charcoal placeholder:text-anchor-lightGray"
                    />
                </div>

                <div className="flex items-center gap-3 ml-4">
                    <button className="p-2 text-anchor-slateText hover:text-anchor-charcoal hover:bg-anchor-ash rounded-md transition-colors">
                        <Filter size={20} />
                    </button>
                    <button
                        onClick={() => setShowAddLinkModal(true)}
                        className="flex items-center gap-2 px-4 py-2 bg-anchor-teal hover:bg-anchor-tealDark text-white rounded-lg font-medium text-sm transition-colors shadow-sm"
                    >
                        <Plus size={18} />
                        Add Link
                    </button>
                </div>
            </div>

            {/* Add Link Modal */}
            <AddLinkModal
                isOpen={showAddLinkModal}
                onClose={() => setShowAddLinkModal(false)}
                onLinkAdded={handleLinkAdded}
                spaces={spaces}
            />

            {/* Content */}
            <div className="flex-1 overflow-y-auto p-6">
                <div className="flex items-center justify-between mb-4">
                    <h2 className="text-lg font-bold text-anchor-charcoal">
                        {getDisplayTitle()}
                    </h2>
                    {!loading && <span className="text-xs text-anchor-slateText">{links.length} anchors</span>}
                </div>

                {loading && (
                    <div className="flex items-center justify-center h-64">
                        <Loader2 className="animate-spin text-anchor-teal" size={32} />
                    </div>
                )}

                {error && (
                    <div className="flex items-center justify-center h-64">
                        <div className="text-center">
                            <p className="text-anchor-error-dark mb-2">Failed to load links</p>
                            <button
                                onClick={loadLinks}
                                className="text-sm text-anchor-teal hover:underline"
                            >
                                Try again
                            </button>
                        </div>
                    </div>
                )}

                {!loading && !error && links.length === 0 && (
                    <div className="flex items-center justify-center h-64">
                        <div className="text-center">
                            <p className="text-anchor-slateText mb-2">No links yet</p>
                            <p className="text-xs text-anchor-lightGray">Click "Add Link" to save your first anchor</p>
                        </div>
                    </div>
                )}

                {!loading && !error && links.length > 0 && (
                    <div className="grid grid-cols-3 gap-4">
                        {links.map(link => (
                            <LinkCard
                                key={link.id}
                                title={link.title || link.url}
                                url={link.url}
                                domain={link.domain || new URL(link.url).hostname}
                                thumbnail={link.thumbnail_url || undefined}
                                tags={link.tags || []}
                                date={db.getRelativeTime(link.created_at)}
                            />
                        ))}
                    </div>
                )}
            </div>
        </div>
    );
};

export default MainContent;
