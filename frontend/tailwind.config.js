/** @type {import('tailwindcss').Config} */
export default {
  darkMode: 'class',
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        navy: '#1D3045',
        surface: '#F5F7F8',
        success: '#2E8B57',
        warning: '#D49A2A',
        critical: '#C94B4B',
        degraded: '#C98A35',
        neutral: '#7B8794',
      },
      fontFamily: {
        sans: ['Helvetica Neue', 'Helvetica', 'Arial', 'sans-serif'],
      },
      letterSpacing: {
        cinematic: '0.18em',
      },
    },
  },
  plugins: [],
}
