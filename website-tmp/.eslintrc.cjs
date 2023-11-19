/** @type {import("eslint").Linter.Config} */
const config = {
  parser: '@typescript-eslint/parser',
  parserOptions: {
    project: true,
  },
  plugins: ['@typescript-eslint'],
  extends: [
    'next/core-web-vitals',
    'plugin:@typescript-eslint/recommended-type-checked',
    'plugin:@typescript-eslint/stylistic-type-checked',
    'prettier',
  ],
  rules: {
    // Turn off formatting base url eslint rules that are handled by prettier (for formatting)
    'semi': 'off',
    'quotes': 'off',
    'comma-dangle': 'off',

    // Typescript eslints (overrides base rule eslints)
    '@typescript-eslint/array-type': 'off',

    '@typescript-eslint/consistent-type-definitions': 'off',
    '@typescript-eslint/consistent-type-imports': [
      'warn',
      {
        prefer: 'type-imports',
        fixStyle: 'inline-type-imports',
      },
    ],

    '@typescript-eslint/ban-ts-comment': 'off',

    '@typescript-eslint/no-explicit-any': 'off',
    '@typescript-eslint/no-floating-promises': 'warn',
    '@typescript-eslint/no-misused-promises': [
      2,
      {
        checksVoidReturn: { attributes: false },
      },
    ],
    '@typescript-eslint/no-unsafe-assignment': 'warn',
    '@typescript-eslint/no-unsafe-call': 'warn',
    '@typescript-eslint/no-unsafe-member-access': 'warn',
    '@typescript-eslint/no-unsafe-return': 'warn',
    '@typescript-eslint/no-unused-vars': ['warn', { argsIgnorePattern: '^_' }],

    // Turn off formatting typsecript-eslint rules that are handled by prettier (for formatting)
    // => https://typescript-eslint.io/linting/troubleshooting/formatting
    '@typescript-eslint/semi': 'off',
    '@typescript-eslint/quotes': 'off',
  },
};

module.exports = config;
