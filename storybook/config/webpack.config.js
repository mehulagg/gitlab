const webpack = require('webpack');
const gitlabWebpackConfig = require('../../config/webpack.config.js');

module.exports = ({ config }) => {
  {
    config.resolve.extensions = Array.from(
      new Set([...config.resolve.extensions, ...gitlabWebpackConfig.resolve.extensions]),
    );
    Object.assign(config.resolve.alias, gitlabWebpackConfig.resolve.alias);
    config.plugins.push(new webpack.IgnorePlugin(/moment/, /pikaday/));

    // @gitlab/svgs uses `gon` to determine the .svg file location, which doesn't exist
    delete config.resolve.alias['@gitlab/svgs/dist/icons.svg'];

    return config;
  }
};
