import React from 'react';
import { AlertCircle, AlertTriangle, Info, RefreshCw } from 'lucide-react';
import type { FriendlyError } from '../utils/errorMessages';

interface ErrorAlertProps extends FriendlyError {
    onRetry?: () => void;
    onDismiss?: () => void;
}

const ErrorAlert: React.FC<ErrorAlertProps> = ({
    message,
    suggestion,
    type = 'error',
    onRetry,
    onDismiss
}) => {
    // Style variants based on error type
    const styles = {
        error: {
            container: 'bg-red-50 border-red-200',
            icon: 'text-red-500',
            title: 'text-red-800',
            suggestion: 'text-red-600'
        },
        warning: {
            container: 'bg-amber-50 border-amber-200',
            icon: 'text-amber-500',
            title: 'text-amber-800',
            suggestion: 'text-amber-600'
        },
        info: {
            container: 'bg-blue-50 border-blue-200',
            icon: 'text-blue-500',
            title: 'text-blue-800',
            suggestion: 'text-blue-600'
        }
    };

    const currentStyle = styles[type];

    // Icon based on type
    const IconComponent = type === 'error'
        ? AlertCircle
        : type === 'warning'
            ? AlertTriangle
            : Info;

    return (
        <div className={`mb-4 p-3 border rounded-lg ${currentStyle.container}`}>
            <div className="flex items-start gap-2">
                <IconComponent
                    size={18}
                    className={`mt-0.5 shrink-0 ${currentStyle.icon}`}
                />
                <div className="flex-1 min-w-0">
                    <p className={`text-sm font-medium ${currentStyle.title}`}>
                        {message}
                    </p>
                    {suggestion && (
                        <p className={`text-xs mt-1 ${currentStyle.suggestion}`}>
                            {suggestion}
                        </p>
                    )}
                </div>
                <div className="flex items-center gap-1 shrink-0">
                    {onRetry && (
                        <button
                            onClick={onRetry}
                            className={`p-1.5 rounded-md hover:bg-white/50 transition-colors ${currentStyle.icon}`}
                            title="Try again"
                        >
                            <RefreshCw size={14} />
                        </button>
                    )}
                    {onDismiss && (
                        <button
                            onClick={onDismiss}
                            className={`p-1.5 rounded-md hover:bg-white/50 transition-colors text-xs ${currentStyle.suggestion}`}
                            title="Dismiss"
                        >
                            ✕
                        </button>
                    )}
                </div>
            </div>
        </div>
    );
};

export default ErrorAlert;
