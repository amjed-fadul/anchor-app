import React, { useEffect, useState } from 'react';
import { Home, Inbox, Plus, Settings, LogOut } from 'lucide-react';
import { db } from '../lib/db';
import type { Space } from '../lib/db';

interface SidebarProps {
    activeTab: string;
    onTabChange: (tab: string) => void;
}

const Sidebar: React.FC<SidebarProps> = ({ activeTab, onTabChange }) => {
    const [spaces, setSpaces] = useState<Space[]>([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        loadSpaces();
    }, []);

    const loadSpaces = async () => {
        try {
            const fetchedSpaces = await db.getSpaces();
            setSpaces(fetchedSpaces);
        } catch (error) {
            console.error('Failed to load spaces:', error);
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="w-64 h-full bg-anchor-ash border-r border-anchor-silver flex flex-col">
            {/* User Profile */}
            <div className="p-4 border-b border-anchor-silver flex items-center gap-3">
                <div className="w-10 h-10 rounded-full bg-anchor-slate flex items-center justify-center text-white font-bold">
                    AF
                </div>
                <div className="flex-1 min-w-0">
                    <h3 className="text-sm font-semibold text-anchor-charcoal truncate">Amjed Fadul</h3>
                    <p className="text-xs text-anchor-slateText truncate">amjed@example.com</p>
                </div>
                <button className="text-anchor-slateText hover:text-anchor-charcoal">
                    <Settings size={16} />
                </button>
            </div>

            {/* Navigation */}
            <div className="p-2 space-y-1 mt-2">
                <button
                    onClick={() => onTabChange('all')}
                    className={`w-full flex items-center gap-3 px-3 py-2 rounded-md text-sm font-medium transition-colors ${activeTab === 'all'
                            ? 'bg-anchor-slate text-white'
                            : 'text-anchor-slateText hover:bg-white hover:text-anchor-charcoal'
                        }`}
                >
                    <Home size={18} />
                    All Links
                </button>
                <button
                    onClick={() => onTabChange('unsorted')}
                    className={`w-full flex items-center gap-3 px-3 py-2 rounded-md text-sm font-medium transition-colors ${activeTab === 'unsorted'
                            ? 'bg-anchor-slate text-white'
                            : 'text-anchor-slateText hover:bg-white hover:text-anchor-charcoal'
                        }`}
                >
                    <Inbox size={18} />
                    Unsorted
                </button>
            </div>

            {/* Spaces */}
            <div className="flex-1 overflow-y-auto px-2 mt-4">
                <div className="flex items-center justify-between px-3 mb-2">
                    <h4 className="text-xs font-semibold text-anchor-lightGray uppercase tracking-wider">Spaces</h4>
                    <button className="text-anchor-slateText hover:text-anchor-teal transition-colors">
                        <Plus size={14} />
                    </button>
                </div>

                {loading ? (
                    <div className="px-3 py-2 text-xs text-anchor-slateText">Loading...</div>
                ) : (
                    <div className="space-y-1">
                        {spaces.map((space) => (
                            <button
                                key={space.id}
                                onClick={() => onTabChange(`space:${space.id}`)}
                                className={`w-full flex items-center gap-3 px-3 py-2 rounded-md text-sm transition-colors ${activeTab === `space:${space.id}`
                                        ? 'bg-white text-anchor-charcoal font-medium'
                                        : 'text-anchor-slateText hover:bg-white hover:text-anchor-charcoal'
                                    }`}
                            >
                                <span
                                    className="w-3 h-3 rounded-sm"
                                    style={{ backgroundColor: space.color }}
                                ></span>
                                {space.name}
                            </button>
                        ))}
                    </div>
                )}
            </div>

            {/* Footer */}
            <div className="p-4 border-t border-anchor-silver">
                <button className="w-full flex items-center gap-2 text-sm text-anchor-slateText hover:text-anchor-error-light transition-colors">
                    <LogOut size={16} />
                    Sign Out
                </button>
            </div>
        </div>
    );
};

export default Sidebar;
