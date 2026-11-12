/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        oqoody: {
          bg: '#081810',
          dark: '#0D2818',
          card: '#133827',
          border: '#1B4D3E',
          gold: '#D4AF37',
          goldHover: '#C5A028',
          textLight: '#F4F6F5',
          textMuted: '#A0B2A6',
          success: '#10B981',
          warning: '#F59E0B',
          danger: '#EF4444',
          accent: '#1B4D3E',
        }
      },
      fontFamily: {
        cairo: ['Cairo', 'sans-serif'],
      },
      boxShadow: {
        'gold-glow': '0 0 15px rgba(212, 175, 55, 0.2)',
        'emerald-glow': '0 0 20px rgba(19, 56, 39, 0.4)',
      }
    },
  },
  plugins: [],
}

