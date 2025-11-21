import React, { useState } from 'react';
import { X, Loader2, ExternalLink } from 'lucide-react';
import { db } from '../lib/db';
import type { Space } from '../lib/db';
import { validateUrl, ensureProtocol, normalizeUrl, extractDomain, getCurrentTab } from '../utils/urlHelpers';

interface AddLinkModalProps {
    isOpen: boolean;
    onClose: () => void;
    onLinkAdded: () => void;
    spaces: Space[];
}

const AddLinkModal: React.FC<AddLinkModalProps> = ({ isOpen, onClose, onLinkAdded, spaces }) => {
    const [url, setUrl] = useState('');
    const [title, setTitle] = useState('');
    const [note, setNote] = useState('');
    const [selectedSpaceId, setSelectedSpaceId] = useState<string | null>(null);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState<string | null>(null);

    if (!isOpen) return null;

    const handleUseCurrentTab = async () => {
        const tabInfo = await getCurrentTab();
        if (tabInfo) {
            setUrl(tabInfo.url);
            setTitle(tabInfo.title);
        }
    };

    const handleSave = async () => {
        const validationError = validateUrl(url);
        if (validationError) {
            setError(validationError);
            return;
        }

        setLoading(true);
        setError(null);

        try {
            const fullUrl = ensureProtocol(url);

            // If title is empty, try to extract from URL or use domain
            if (!title.trim()) {
                setTitle(extractDomain(fullUrl));
            }

            const normalized = normalizeUrl(fullUrl);
            const domain = extractDomain(fullUrl);

            await db.createLink({
                url: fullUrl,
                normalizedUrl: normalized,
                title: title.trim() || domain,
                domain,
                note: note.trim() || null,
                spaceId: selectedSpaceId,
            });

            // Success! Close modal and notify parent
            onLinkAdded();
            handleClose();
        } catch (err: any) {
            setError(err.message || 'Failed to save link');
        } finally {
            setLoading(false);
        }
    };

    const handleClose = () => {
        setUrl('');
        setTitle('');
        setNote('');
        setSelectedSpaceId(null);
        setError(null);
        onClose();
    };

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50" onClick={handleClose}>
            <div
                className="bg-white rounded-xl shadow-xl w-full max-w-md mx-4 overflow-hidden"
                onClick={(e) => e.stopPropagation()}
            >
                {/* Header */}
                <div className="flex items-center justify-between px-6 py-4 border-b border-anchor-silver">
                    <h2 className="text-lg font-bold text-anchor-charcoal">Add Link</h2>
                    <button
                        onClick={handleClose}
                        className="text-anchor-slateText hover:text-anchor-charcoal transition-colors"
                    >
                        <X size={20} />
                    </button>
                </div>

                {/* Content */}
                <div className="p-6">
                    {error && (
                        <div className="mb-4 p-3 bg-anchor-error-light/10 border border-anchor-error-light rounded-lg text-sm text-anchor-error-dark">
                            {error}
                        </div>
                    )}

                    <div className="space-y-4">
                        {/* URL Input */}
                        <div>
                            <label className="block text-sm font-medium text-anchor-charcoal mb-2">
                                URL <span className="text-anchor-error-light">*</span>
                            </label>
                            <input
                                type="url"
                                value={url}
                                onChange={(e) => setUrl(e.target.value)}
                                placeholder="https://example.com"
                                className="w-full px-3 py-2 border border-anchor-silver rounded-lg text-sm focus:ring-2 focus:ring-anchor-teal focus:outline-none"
                                autoFocus
                            />
                        </div>

                        {/* Use Current Tab Button */}
                        <button
                            onClick={handleUseCurrentTab}
                            className="flex items-center gap-2 text-sm text-anchor-teal hover:text-anchor-tealDark transition-colors"
                        >
                            <ExternalLink size={16} />
                            Use Current Tab
                        </button>

                        {/* Title Input */}
                        <div>
                            <label className="block text-sm font-medium text-anchor-charcoal mb-2">
                                Title
                            </label>
                            <input
                                type="text"
                                value={title}
                                onChange={(e) => setTitle(e.target.value)}
                                placeholder="Link title (optional - will use domain if empty)"
                                className="w-full px-3 py-2 border border-anchor-silver rounded-lg text-sm focus:ring-2 focus:ring-anchor-teal focus:outline-none"
                            />
                        </div>

                        {/* Space Selector */}
                        <div>
                            <label className="block text-sm font-medium text-anchor-charcoal mb-2">
                                Space
                            </label>
                            <select
                                value={selectedSpaceId || ''}
                                onChange={(e) => setSelectedSpaceId(e.target.value || null)}
                                className="w-full px-3 py-2 border border-anchor-silver rounded-lg text-sm focus:ring-2 focus:ring-anchor-teal focus:outline-none"
                            >
                                <option value="">Unsorted</option>
                                {spaces.map((space) => (
                                    <option key={space.id} value={space.id}>
                                        {space.name}
                                    </option>
                                ))}
                            </select>
                        </div>

                        {/* Note */}
                        <div>
                            <label className="block text-sm font-medium text-anchor-charcoal mb-2">
                                Note
                            </label>
                            <textarea
                                value={note}
                                onChange={(e) => {
                                    if (e.target.value.length <= 200) {
                                        setNote(e.target.value);
                                    }
                                }}
                                placeholder="Why are you saving this? (optional)"
                                rows={3}
                                className="w-full px-3 py-2 border border-anchor-silver rounded-lg text-sm focus:ring-2 focus:ring-anchor-teal focus:outline-none resize-none"
                            />
                            <div className="mt-1 text-xs text-anchor-slateText text-right">
                                {note.length}/200
                            </div>
                        </div>

                        {/* Buttons */}
                        <div className="flex gap-3 pt-2">
                            <button
                                onClick={handleClose}
                                disabled={loading}
                                className="flex-1 py-2.5 border border-anchor-silver rounded-lg font-medium text-sm text-anchor-charcoal hover:bg-anchor-ash transition-colors disabled:opacity-50"
                            >
                                Cancel
                            </button>
                            <button
                                onClick={handleSave}
                                disabled={loading || !url.trim()}
                                className="flex-1 flex items-center justify-center gap-2 py-2.5 bg-anchor-teal hover:bg-anchor-tealDark text-white rounded-lg font-medium text-sm transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                            >
                                {loading && <Loader2 size={16} className="animate-spin" />}
                                Save
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
};

export default AddLinkModal;
