const webpack = require('webpack');
const webpackConfig = require('../config/webpack.config.js');

module.exports = ({ config }) => {
  {
    config.resolve.extensions = Array.from(
      new Set([...config.resolve.extensions, ...webpackConfig.resolve.extensions]),
    );
    Object.assign(config.resolve.alias, webpackConfig.resolve.alias);
    config.plugins.push(new webpack.IgnorePlugin(/moment/, /pikaday/));

    // this looks for `gon`, which doesn't exist
    delete config.resolve.alias['@gitlab/svgs/dist/icons.svg'];

    return config;
  }
};
