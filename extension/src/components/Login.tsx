import React, { useState } from 'react';
import { supabase } from '../lib/supabase';
import { Mail, Lock, Loader2, AlertCircle } from 'lucide-react';

interface LoginProps {
    onLoginSuccess: () => void;
}

const Login: React.FC<LoginProps> = ({ onLoginSuccess }) => {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState<string | null>(null);
    const [isSignUp, setIsSignUp] = useState(false);

    const handleAuth = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        setError(null);

        try {
            if (isSignUp) {
                const { error } = await supabase.auth.signUp({
                    email,
                    password,
                });
                if (error) throw error;
                setError('Check your email for the confirmation link!');
            } else {
                const { error } = await supabase.auth.signInWithPassword({
                    email,
                    password,
                });
                if (error) throw error;
                onLoginSuccess();
            }
        } catch (err: any) {
            setError(err.message);
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="flex flex-col items-center justify-center h-full bg-anchor-ash p-8">
            <div className="w-full max-w-xs bg-white p-6 rounded-xl shadow-sm border border-anchor-silver">
                <div className="text-center mb-6">
                    <div className="w-12 h-12 bg-anchor-slate rounded-lg flex items-center justify-center mx-auto mb-3 text-2xl">
                        ⚓
                    </div>
                    <h2 className="text-xl font-bold text-anchor-charcoal">
                        {isSignUp ? 'Create Account' : 'Welcome Back'}
                    </h2>
                    <p className="text-sm text-anchor-slateText mt-1">
                        {isSignUp ? 'Sign up to start anchoring links' : 'Sign in to your Anchor space'}
                    </p>
                </div>

                {error && (
                    <div className={`mb-4 p-3 rounded-lg text-xs flex items-start gap-2 ${error.includes('Check your email')
                            ? 'bg-anchor-success-light/10 text-anchor-success-dark'
                            : 'bg-anchor-error-light/10 text-anchor-error-dark'
                        }`}>
                        <AlertCircle size={14} className="mt-0.5 shrink-0" />
                        <span>{error}</span>
                    </div>
                )}

                <form onSubmit={handleAuth} className="space-y-4">
                    <div>
                        <label className="block text-xs font-medium text-anchor-slateText mb-1">Email</label>
                        <div className="relative">
                            <Mail className="absolute left-3 top-1/2 -translate-y-1/2 text-anchor-lightGray" size={16} />
                            <input
                                type="email"
                                value={email}
                                onChange={(e) => setEmail(e.target.value)}
                                className="w-full pl-9 pr-3 py-2 bg-anchor-ash border-none rounded-lg text-sm focus:ring-2 focus:ring-anchor-teal focus:outline-none text-anchor-charcoal"
                                placeholder="you@example.com"
                                required
                            />
                        </div>
                    </div>

                    <div>
                        <label className="block text-xs font-medium text-anchor-slateText mb-1">Password</label>
                        <div className="relative">
                            <Lock className="absolute left-3 top-1/2 -translate-y-1/2 text-anchor-lightGray" size={16} />
                            <input
                                type="password"
                                value={password}
                                onChange={(e) => setPassword(e.target.value)}
                                className="w-full pl-9 pr-3 py-2 bg-anchor-ash border-none rounded-lg text-sm focus:ring-2 focus:ring-anchor-teal focus:outline-none text-anchor-charcoal"
                                placeholder="••••••••"
                                required
                            />
                        </div>
                    </div>

                    <button
                        type="submit"
                        disabled={loading}
                        className="w-full flex items-center justify-center gap-2 py-2 bg-anchor-teal hover:bg-anchor-tealDark text-white rounded-lg font-medium text-sm transition-colors disabled:opacity-70 disabled:cursor-not-allowed"
                    >
                        {loading && <Loader2 size={16} className="animate-spin" />}
                        {isSignUp ? 'Sign Up' : 'Sign In'}
                    </button>
                </form>

                <div className="mt-4 text-center">
                    <button
                        onClick={() => {
                            setIsSignUp(!isSignUp);
                            setError(null);
                        }}
                        className="text-xs text-anchor-slateText hover:text-anchor-teal transition-colors"
                    >
                        {isSignUp ? 'Already have an account? Sign In' : "Don't have an account? Sign Up"}
                    </button>
                </div>
            </div>
        </div>
    );
};

export default Login;
