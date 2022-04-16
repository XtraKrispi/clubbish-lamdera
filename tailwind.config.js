const plugin = require("tailwindcss/plugin");

const perspective = plugin(function ({ addUtilities }) {
  addUtilities({
    ".perspective-600": {
      perspective: "600px"
    }
  })
});

const rotateY = plugin(function ({ addUtilities }) {
  addUtilities({
    ".rotate-y-20": {
      transform: 'rotateY(20deg)'
    },
    ".rotate-y-180": {
      transform: 'rotateY(180deg)'
    }
  })
});

module.exports = {
  content: ["./src/**/*.{html,js,elm}"],
  theme: {
    extend: {},
  },
  plugins: [rotateY, perspective],
}
