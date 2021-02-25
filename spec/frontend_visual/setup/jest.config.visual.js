module.exports = {
  "verbose": true,
  "moduleFileExtensions": [
    "js",
    "json",
    "vue"
  ],
  "moduleNameMapper": {
    "^~/(.*)$": "<rootDir>/src/$1",
    "^@gitlab/ui$": "<rootDir>/index.js",
    "\\.(css|scss|less)$": "identity-obj-proxy"
  },
  "transform": {
    "^.+\\.js$": "babel-jest",
    ".*\\.example.(vue)$": "vue-jest",
    ".*\\.(vue)$": "vue-jest",
    "\\.(svg|html)$": "jest-raw-loader",
  },
  transformIgnorePatterns: ['/node_modules/(?!(@storybook/.*\\.vue$))'],
}
