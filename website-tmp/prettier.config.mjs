/** @type {import('prettier').Config & import('prettier-plugin-tailwindcss').options} */
const config = {
  plugins: [
    'prettier-plugin-organize-imports',
    // 'prettier-plugin-tailwindcss',
  ],
  overrides: [
    {
      files: ['**/.vscode/*.json', '**/tsconfig.json', '**/tsconfig.*.json'],
      options: {
        parser: 'json5',
        quoteProps: 'preserve',
      },
    },
    {
      files: ['**/*.ts', '**/*.tsx'],
      options: {
        semi: false,
        trailingComma: 'none',
        singleQuote: true,
        jsxSingleQuote: true,
        printWidth: 120,
        tabWidth: 2,
        trailingCommans: 'es5',
      },
    },
  ],
  // ALL rules
};

export default config;
