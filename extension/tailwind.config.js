/** @type {import('tailwindcss').Config} */
export default {
    content: [
        "./index.html",
        "./src/**/*.{js,ts,jsx,tsx}",
    ],
    theme: {
        extend: {
            colors: {
                anchor: {
                    slate: '#2C3E50',
                    teal: '#0D9488',
                    charcoal: '#1A1A1A',
                    slateText: '#4A5568',
                    silver: '#CBD5E1',
                    ash: '#F1F5F9',
                    deepCharcoal: '#0F172A',
                    darkSlate: '#1E293B',
                    offWhite: '#F8FAFC',
                    lightGray: '#94A3B8',
                    darkBorder: '#334155',
                    tealDark: '#14B8A6',
                },
                success: {
                    light: '#059669',
                    dark: '#10B981',
                },
                warning: {
                    light: '#D97706',
                    dark: '#F59E0B',
                },
                error: {
                    light: '#DC2626',
                    dark: '#EF4444',
                }
            },
            fontFamily: {
                sans: ['Geist', 'sans-serif'],
            },
            backgroundImage: {
                'success-gradient': 'linear-gradient(135deg, #10B981 0%, #0D9488 100%)',
            }
        },
    },
    plugins: [],
}
