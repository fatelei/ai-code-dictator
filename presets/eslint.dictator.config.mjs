// presets/eslint.dictator.config.mjs
// Drop into your ESLint flat config to enforce zero-tolerance AI guardrails.

export default [
  {
    rules: {
      // 1. Ban useEffect by default
      "no-restricted-syntax": [
        "error",
        {
          selector: "CallExpression[callee.name='useEffect']",
          message:
            "[Code Dictator] useEffect is banned. Derive state during render or trigger side effects in event handlers.",
        },
        {
          selector:
            "MemberExpression[object.name='React'][property.name='useEffect']",
          message:
            "[Code Dictator] React.useEffect is banned. Derive state during render or trigger side effects in event handlers.",
        },
      ],

      // 2. Ban AI slop comments (TODO/FIXME/AI narration left behind)
      "no-warning-comments": [
        "error",
        {
          terms: ["todo", "fixme", "hack", "xxx", "ai generated", "claude", "cursor"],
          location: "anywhere",
        },
      ],

      // 3. Anti-bloat complexity & nesting ceilings
      "max-depth": ["error", 3],
      "max-lines-per-function": ["error", { max: 50, skipBlankLines: true, skipComments: true }],
      "complexity": ["error", 10],
      "no-empty": ["error", { allowEmptyCatch: false }],
    },
  },
];
