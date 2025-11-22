import React, { useState, useEffect } from 'react';
import { X, Loader2, ExternalLink, Plus, ChevronDown } from 'lucide-react';
import { db } from '../lib/db';
import type { Space, Tag } from '../lib/db';
import { fetchMetadata } from '../lib/metadata';
import type { LinkMetadata } from '../lib/metadata';
import { validateUrl, ensureProtocol, normalizeUrl, extractDomain, getCurrentTab } from '../utils/urlHelpers';
import { getUserFriendlyError, type FriendlyError } from '../utils/errorMessages';
import ErrorAlert from './ErrorAlert';

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
    const [error, setError] = useState<FriendlyError | null>(null);
    const [step, setStep] = useState<'input' | 'details'>('input');
    const [metadata, setMetadata] = useState<LinkMetadata | null>(null);

    // Space dropdown state
    const [showSpaceDropdown, setShowSpaceDropdown] = useState(false);

    // Tag state
    const [availableTags, setAvailableTags] = useState<Tag[]>([]);
    const [selectedTagIds, setSelectedTagIds] = useState<string[]>([]);
    const [tagInput, setTagInput] = useState('');
    const [showTagSuggestions, setShowTagSuggestions] = useState(false);

    // Load tags when entering details step
    useEffect(() => {
        if (step === 'details') {
            loadTags();
        }
    }, [step]);

    const loadTags = async () => {
        try {
            const tags = await db.getTags();
            setAvailableTags(tags);
        } catch (err) {
            console.error('Failed to load tags:', err);
        }
    };

    if (!isOpen) return null;

    const handleUseCurrentTab = async () => {
        const tabInfo = await getCurrentTab();
        if (tabInfo) {
            setUrl(tabInfo.url);
            setTitle(tabInfo.title);
        }
    };

    const handleContinue = async () => {
        const validationError = validateUrl(url);
        if (validationError) {
            setError(getUserFriendlyError(new Error(validationError)));
            return;
        }

        setLoading(true);
        setError(null);

        try {
            const fullUrl = ensureProtocol(url);

            // Fetch metadata from Edge Function
            console.log('Fetching metadata for:', fullUrl);
            const fetchedMetadata = await fetchMetadata(fullUrl);
            console.log('Metadata received:', fetchedMetadata);
            setMetadata(fetchedMetadata);

            // Pre-fill title from metadata
            setTitle(fetchedMetadata.title);

            // Move to details step
            setStep('details');
        } catch (err: any) {
            console.error('Metadata fetch error:', err);
            // Show user-friendly error but still allow proceeding
            setError({
                message: "Couldn't load page preview",
                suggestion: "Your link will be saved with basic info",
                type: 'warning'
            });
            // Still move to details step with domain as title
            const domain = extractDomain(ensureProtocol(url));
            setTitle(domain);
            setStep('details');
        } finally {
            setLoading(false);
        }
    };

    const handleSave = async () => {
        setLoading(true);
        setError(null);

        try {
            const fullUrl = ensureProtocol(url);
            const normalized = normalizeUrl(fullUrl);
            const domain = extractDomain(fullUrl);

            await db.createLink({
                url: fullUrl,
                normalizedUrl: normalized,
                title: title.trim() || domain,
                description: metadata?.description || null,
                thumbnailUrl: metadata?.thumbnailUrl || null,
                domain,
                note: note.trim() || null,
                spaceId: selectedSpaceId,
                tagIds: selectedTagIds,
            });

            // Success! Close modal and notify parent
            onLinkAdded();
            handleClose();
        } catch (err: any) {
            console.error('Save link error:', err);
            // Convert to user-friendly error
            setError(getUserFriendlyError(err));
        } finally {
            setLoading(false);
        }
    };

    const handleClose = () => {
        setUrl('');
        setTitle('');
        setNote('');
        setSelectedSpaceId(null);
        setMetadata(null);
        setError(null);
        setStep('input');
        // Reset space dropdown state
        setShowSpaceDropdown(false);
        // Reset tag state
        setSelectedTagIds([]);
        setTagInput('');
        setShowTagSuggestions(false);
        onClose();
    };

    // Tag helper functions
    const filteredTags = availableTags.filter(
        (tag) =>
            tag.name.toLowerCase().includes(tagInput.toLowerCase()) &&
            !selectedTagIds.includes(tag.id)
    );

    const selectedTags = availableTags.filter((tag) => selectedTagIds.includes(tag.id));

    const handleTagSelect = (tagId: string) => {
        setSelectedTagIds([...selectedTagIds, tagId]);
        setTagInput('');
        setShowTagSuggestions(false);
    };

    const handleTagRemove = (tagId: string) => {
        setSelectedTagIds(selectedTagIds.filter((id) => id !== tagId));
    };

    const handleCreateTag = async () => {
        if (!tagInput.trim()) return;
        try {
            const newTag = await db.getOrCreateTag(tagInput.trim());
            setAvailableTags([...availableTags, newTag]);
            setSelectedTagIds([...selectedTagIds, newTag.id]);
            setTagInput('');
            setShowTagSuggestions(false);
        } catch (err) {
            console.error('Failed to create tag:', err);
        }
    };

    const handleTagInputKeyDown = (e: React.KeyboardEvent) => {
        if (e.key === 'Enter' && tagInput.trim()) {
            e.preventDefault();
            // If there's an exact match, select it; otherwise create new
            const exactMatch = filteredTags.find(
                (tag) => tag.name.toLowerCase() === tagInput.toLowerCase()
            );
            if (exactMatch) {
                handleTagSelect(exactMatch.id);
            } else {
                handleCreateTag();
            }
        }
    };

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50" onClick={handleClose}>
            <div
                className="bg-white rounded-xl shadow-xl w-full max-w-md mx-4 overflow-hidden"
                onClick={(e) => e.stopPropagation()}
            >
                {/* Header */}
                <div className="flex items-center justify-between px-6 py-4 border-b border-anchor-silver">
                    <h2 className="text-lg font-bold text-anchor-charcoal">
                        {step === 'input' ? 'Add Link' : 'Link Details'}
                    </h2>
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
                        <ErrorAlert
                            message={error.message}
                            suggestion={error.suggestion}
                            type={error.type}
                            onDismiss={() => setError(null)}
                        />
                    )}

                    {step === 'input' ? (
                        <>
                            {/* URL Input Step */}
                            <div className="space-y-4">
                                <div>
                                    <label className="block text-sm font-medium text-anchor-charcoal mb-2">
                                        Paste Link
                                    </label>
                                    <input
                                        type="url"
                                        value={url}
                                        onChange={(e) => setUrl(e.target.value)}
                                        placeholder="https://example.com"
                                        className="w-full px-3 py-2 border border-anchor-silver rounded-lg text-sm focus:ring-2 focus:ring-anchor-teal focus:outline-none"
                                        autoFocus
                                        onKeyDown={(e) => {
                                            if (e.key === 'Enter' && url.trim()) {
                                                handleContinue();
                                            }
                                        }}
                                    />
                                </div>

                                <button
                                    onClick={handleUseCurrentTab}
                                    className="flex items-center gap-2 text-sm text-anchor-teal hover:text-anchor-tealDark transition-colors"
                                >
                                    <ExternalLink size={16} />
                                    Use Current Tab
                                </button>

                                <button
                                    onClick={handleContinue}
                                    disabled={loading || !url.trim()}
                                    className="w-full flex items-center justify-center gap-2 py-2.5 bg-anchor-teal hover:bg-anchor-tealDark text-white rounded-lg font-medium text-sm transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                                >
                                    {loading && <Loader2 size={16} className="animate-spin" />}
                                    {loading ? 'Fetching metadata...' : 'Continue'}
                                </button>
                            </div>
                        </>
                    ) : (
                        <>
                            {/* Details Step */}
                            <div className="space-y-4">
                                {/* Show thumbnail if available */}
                                {metadata?.thumbnailUrl && (
                                    <div className="w-full h-32 rounded-lg overflow-hidden bg-anchor-ash">
                                        <img
                                            src={metadata.thumbnailUrl}
                                            alt="Link preview"
                                            className="w-full h-full object-cover"
                                            onError={(e) => {
                                                // Hide image if it fails to load
                                                (e.target as HTMLElement).style.display = 'none';
                                            }}
                                        />
                                    </div>
                                )}

                                <div>
                                    <label className="block text-sm font-medium text-anchor-charcoal mb-2">
                                        Title
                                    </label>
                                    <input
                                        type="text"
                                        value={title}
                                        onChange={(e) => setTitle(e.target.value)}
                                        placeholder="Link title"
                                        className="w-full px-3 py-2 border border-anchor-silver rounded-lg text-sm focus:ring-2 focus:ring-anchor-teal focus:outline-none"
                                    />
                                </div>

                                <div>
                                    <label className="block text-sm font-medium text-anchor-charcoal mb-2">
                                        Space
                                    </label>
                                    <div className="relative">
                                        <button
                                            type="button"
                                            onClick={() => setShowSpaceDropdown(!showSpaceDropdown)}
                                            className="w-full flex items-center justify-between px-3 py-2 border border-anchor-silver rounded-lg text-sm focus:ring-2 focus:ring-anchor-teal focus:outline-none bg-white text-left"
                                        >
                                            <span className="flex items-center gap-2">
                                                <span
                                                    className="w-3 h-3 rounded-sm shrink-0"
                                                    style={{
                                                        backgroundColor: selectedSpaceId
                                                            ? spaces.find(s => s.id === selectedSpaceId)?.color || '#d1d5db'
                                                            : '#d1d5db'
                                                    }}
                                                />
                                                {selectedSpaceId
                                                    ? spaces.find(s => s.id === selectedSpaceId)?.name || 'Unsorted'
                                                    : 'Unsorted'}
                                            </span>
                                            <ChevronDown
                                                size={16}
                                                className={`text-anchor-slateText transition-transform ${showSpaceDropdown ? 'rotate-180' : ''}`}
                                            />
                                        </button>

                                        {showSpaceDropdown && (
                                            <div className="absolute z-10 w-full mt-1 bg-white border border-anchor-silver rounded-lg shadow-lg max-h-48 overflow-y-auto">
                                                {/* Unsorted option */}
                                                <button
                                                    type="button"
                                                    onClick={() => {
                                                        setSelectedSpaceId(null);
                                                        setShowSpaceDropdown(false);
                                                    }}
                                                    className={`w-full flex items-center gap-2 px-3 py-2 text-sm text-left hover:bg-anchor-ash transition-colors ${
                                                        selectedSpaceId === null ? 'bg-anchor-ash' : ''
                                                    }`}
                                                >
                                                    <span className="w-3 h-3 rounded-sm bg-gray-300 shrink-0" />
                                                    Unsorted
                                                </button>

                                                {/* Space options */}
                                                {spaces.map((space) => (
                                                    <button
                                                        key={space.id}
                                                        type="button"
                                                        onClick={() => {
                                                            setSelectedSpaceId(space.id);
                                                            setShowSpaceDropdown(false);
                                                        }}
                                                        className={`w-full flex items-center gap-2 px-3 py-2 text-sm text-left hover:bg-anchor-ash transition-colors ${
                                                            selectedSpaceId === space.id ? 'bg-anchor-ash' : ''
                                                        }`}
                                                    >
                                                        <span
                                                            className="w-3 h-3 rounded-sm shrink-0"
                                                            style={{ backgroundColor: space.color }}
                                                        />
                                                        {space.name}
                                                    </button>
                                                ))}
                                            </div>
                                        )}
                                    </div>
                                </div>

                                {/* Tags */}
                                <div>
                                    <label className="block text-sm font-medium text-anchor-charcoal mb-2">
                                        Tags
                                    </label>

                                    {/* Selected Tags */}
                                    {selectedTags.length > 0 && (
                                        <div className="flex flex-wrap gap-2 mb-2">
                                            {selectedTags.map((tag) => (
                                                <span
                                                    key={tag.id}
                                                    className="inline-flex items-center gap-1 px-2 py-1 rounded-full text-xs font-medium text-white"
                                                    style={{ backgroundColor: tag.color }}
                                                >
                                                    {tag.name}
                                                    <button
                                                        type="button"
                                                        onClick={() => handleTagRemove(tag.id)}
                                                        className="hover:bg-white/20 rounded-full p-0.5"
                                                    >
                                                        <X size={12} />
                                                    </button>
                                                </span>
                                            ))}
                                        </div>
                                    )}

                                    {/* Tag Input */}
                                    <div className="relative">
                                        <input
                                            type="text"
                                            value={tagInput}
                                            onChange={(e) => {
                                                setTagInput(e.target.value);
                                                setShowTagSuggestions(true);
                                            }}
                                            onFocus={() => setShowTagSuggestions(true)}
                                            onBlur={() => {
                                                // Delay hiding to allow click on suggestions
                                                setTimeout(() => setShowTagSuggestions(false), 200);
                                            }}
                                            onKeyDown={handleTagInputKeyDown}
                                            placeholder="Type to add tags..."
                                            className="w-full px-3 py-2 border border-anchor-silver rounded-lg text-sm focus:ring-2 focus:ring-anchor-teal focus:outline-none"
                                        />

                                        {/* Tag Suggestions Dropdown */}
                                        {showTagSuggestions && (tagInput || filteredTags.length > 0) && (
                                            <div className="absolute z-10 w-full mt-1 bg-white border border-anchor-silver rounded-lg shadow-lg max-h-40 overflow-y-auto">
                                                {filteredTags.slice(0, 5).map((tag) => (
                                                    <button
                                                        key={tag.id}
                                                        type="button"
                                                        onClick={() => handleTagSelect(tag.id)}
                                                        className="w-full flex items-center gap-2 px-3 py-2 text-sm text-left hover:bg-anchor-ash transition-colors"
                                                    >
                                                        <span
                                                            className="w-3 h-3 rounded-full"
                                                            style={{ backgroundColor: tag.color }}
                                                        />
                                                        {tag.name}
                                                    </button>
                                                ))}
                                                {tagInput.trim() && !filteredTags.some(
                                                    (tag) => tag.name.toLowerCase() === tagInput.toLowerCase()
                                                ) && (
                                                    <button
                                                        type="button"
                                                        onClick={handleCreateTag}
                                                        className="w-full flex items-center gap-2 px-3 py-2 text-sm text-left text-anchor-teal hover:bg-anchor-ash transition-colors"
                                                    >
                                                        <Plus size={14} />
                                                        Create "{tagInput.trim()}"
                                                    </button>
                                                )}
                                            </div>
                                        )}
                                    </div>
                                </div>

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

                                <div className="flex gap-3">
                                    <button
                                        onClick={() => setStep('input')}
                                        disabled={loading}
                                        className="flex-1 py-2.5 border border-anchor-silver rounded-lg font-medium text-sm text-anchor-charcoal hover:bg-anchor-ash transition-colors disabled:opacity-50"
                                    >
                                        Back
                                    </button>
                                    <button
                                        onClick={handleSave}
                                        disabled={loading}
                                        className="flex-1 flex items-center justify-center gap-2 py-2.5 bg-anchor-teal hover:bg-anchor-tealDark text-white rounded-lg font-medium text-sm transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                                    >
                                        {loading && <Loader2 size={16} className="animate-spin" />}
                                        Save
                                    </button>
                                </div>
                            </div>
                        </>
                    )}
                </div>
            </div>
        </div>
    );
};

export default AddLinkModal;
