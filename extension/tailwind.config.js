/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Geist', 'system-ui', 'sans-serif'],
      },
      spacing: {
        // 8px spacing system (matching mobile app)
        '1': '8px',
        '2': '16px',
        '3': '24px',
        '4': '32px',
        '5': '40px',
        '6': '48px',
        '7': '56px',
        '8': '64px',
      },
      colors: {
        // Anchor brand colors (matching mobile app)
        primary: {
          DEFAULT: '#000000',
          foreground: '#FFFFFF',
        },
        secondary: {
          DEFAULT: '#F5F5F5',
          foreground: '#000000',
        },
        // Space colors (14-color palette from mobile)
        space: {
          purple: '#9b87f5',
          red: '#f97066',
          orange: '#fb923c',
          yellow: '#fbbf24',
          green: '#4ade80',
          teal: '#2dd4bf',
          blue: '#60a5fa',
          indigo: '#818cf8',
          pink: '#f472b6',
          gray: '#9ca3af',
          brown: '#a16207',
          olive: '#84cc16',
          navy: '#3b82f6',
          maroon: '#dc2626',
        },
      },
    },
  },
  plugins: [],
}
