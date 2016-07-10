module.exports = {
  "extends": "airbnb",
  "plugins": [
    "react"
  ],
  "settings": {
    "import/resolver": {
      "webpack": {
        "config": "webpack.config.js"
      }
    }
  },
  "rules": {
    "semi": ["error", "never"],
    "space-before-function-paren": ["error", "never"]
  }
};
