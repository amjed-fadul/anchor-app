import React from 'react';
import { MoreHorizontal, ExternalLink, Copy } from 'lucide-react';

interface LinkCardProps {
    title: string;
    url: string;
    domain: string;
    thumbnail?: string;
    tags?: string[];
    date: string;
}

const LinkCard: React.FC<LinkCardProps> = ({ title, url, domain, thumbnail, tags = [], date }) => {
    return (
        <div className="group relative bg-white border border-anchor-silver rounded-lg overflow-hidden hover:shadow-md transition-shadow">
            {/* Thumbnail */}
            <div className="aspect-video bg-anchor-ash relative overflow-hidden">
                {thumbnail ? (
                    <img src={thumbnail} alt={title} className="w-full h-full object-cover" />
                ) : (
                    <div className="w-full h-full flex items-center justify-center text-anchor-slateText">
                        <span className="text-4xl opacity-20">⚓</span>
                    </div>
                )}

                {/* Hover Actions */}
                <div className="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center gap-2">
                    <button
                        className="p-2 bg-white rounded-full text-anchor-slate hover:text-anchor-teal transition-colors"
                        title="Open"
                        onClick={() => window.open(url, '_blank')}
                    >
                        <ExternalLink size={16} />
                    </button>
                    <button
                        className="p-2 bg-white rounded-full text-anchor-slate hover:text-anchor-teal transition-colors"
                        title="Copy URL"
                        onClick={() => navigator.clipboard.writeText(url)}
                    >
                        <Copy size={16} />
                    </button>
                </div>
            </div>

            {/* Content */}
            <div className="p-3">
                <div className="flex items-start justify-between gap-2">
                    <h3 className="text-sm font-semibold text-anchor-charcoal line-clamp-2 leading-tight mb-1" title={title}>
                        {title}
                    </h3>
                    <button className="text-anchor-slateText hover:text-anchor-charcoal opacity-0 group-hover:opacity-100 transition-opacity">
                        <MoreHorizontal size={16} />
                    </button>
                </div>

                <p className="text-xs text-anchor-slateText mb-2 truncate">{domain}</p>

                {/* Tags */}
                <div className="flex flex-wrap gap-1 mb-2">
                    {tags.slice(0, 3).map((tag, index) => (
                        <span key={index} className="inline-flex items-center px-1.5 py-0.5 rounded text-[10px] font-medium bg-anchor-ash text-anchor-slateText">
                            {tag}
                        </span>
                    ))}
                    {tags.length > 3 && (
                        <span className="inline-flex items-center px-1.5 py-0.5 rounded text-[10px] font-medium bg-anchor-ash text-anchor-slateText">
                            +{tags.length - 3}
                        </span>
                    )}
                </div>

                {/* Footer */}
                <div className="flex items-center justify-between mt-2 pt-2 border-t border-anchor-ash">
                    <span className="text-[10px] text-anchor-lightGray">{date}</span>
                </div>
            </div>
        </div>
    );
};

export default LinkCard;
