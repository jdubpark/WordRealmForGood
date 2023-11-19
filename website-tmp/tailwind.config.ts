import { type Config } from 'tailwindcss'
import { fontFamily } from 'tailwindcss/defaultTheme'

export default {
  content: ['./src/**/*.tsx'],
  theme: {
    extend: {
      // fontFamily: {
      //   sans: ['var(--font-sans)', ...fontFamily.sans]
      // }
      fontFamily: {
        sans: ['"PT Sans"', ...fontFamily.sans]
      }
    }
  },
  daisyui: {
    themes: ['emerald']
  },
  plugins: [require('daisyui')]
} satisfies Config
