/* eslint-disable no-param-reassign */

const { statSync } = require('fs');
const path = require('path');
const sass = require('node-sass');
const { buildIncludePaths, resolveGlobUrl } = require('node-sass-magic-importer/dist/toolbox');
const webpack = require('webpack');
const gitlabWebpackConfig = require('../../config/webpack.config.js');

const TRANSPARENT_1X1_PNG =
  'url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==)';

function smartImporter(url, prev) {
  const nodeSassOptions = this.options;
  const includePaths = buildIncludePaths(nodeSassOptions.includePaths, prev).filter(
    (includePath) => !includePath.includes('node_modules'),
  );

  // if (url.startsWith('@gitlab/ui')) {
  //   return { file: resolveUrl(url.replace('@gitlab/ui/', ''), includePaths) };
  // }

  // if (url === 'framework/variables') {
  //   return { contents: patchedFrameworkVariables };
  // }

  const filePaths = resolveGlobUrl(url, includePaths);

  if (filePaths) {
    const contents = filePaths
      .filter((file) => statSync(file).isFile())
      .map((x) => `@import '${x}';`)
      .join(`\n`);
    return { contents };
  }

  return null;
}

const ROOT = path.resolve(__dirname, '../../');

const sassIncludePaths = [
  'app/assets/stylesheets',
  'ee/app/assets/stylesheets',
  'ee/app/assets/stylesheets/_ee',
  'node_modules',
].map((p) => path.resolve(ROOT, p));

const sassLoaderOptions = {
  functions: {
    'image-url($url)': function sassImageUrlStub() {
      return new sass.types.String(TRANSPARENT_1X1_PNG);
    },
    'asset_path($url)': function sassAssetPathStub() {
      return new sass.types.String(TRANSPARENT_1X1_PNG);
    },
    'asset_url($url)': function sassAssetUrlStub() {
      return new sass.types.String(TRANSPARENT_1X1_PNG);
    },
    'url($url)': function sassUrlStub() {
      return new sass.types.String(TRANSPARENT_1X1_PNG);
    },
  },
  includePaths: sassIncludePaths,
  importer: smartImporter,
};

module.exports = ({ config }) => {
  config.resolve.extensions = Array.from(
    new Set([...config.resolve.extensions, ...gitlabWebpackConfig.resolve.extensions]),
  );

  Object.assign(config.resolve.alias, gitlabWebpackConfig.resolve.alias);
  delete config.resolve.alias['@gitlab/svgs/dist/icons.svg'];

  config.module.rules = [
    ...config.module.rules.filter((r) => !r.test.test('.css')),
    {
      test: /\.s?css$/,
      exclude: /typescale\/\w+_demo\.scss$/, // skip typescale demo stylesheets
      loaders: [
        'style-loader',
        'css-loader',
        {
          loader: 'sass-loader',
          options: sassLoaderOptions,
        },
      ],
    },
  ];

  config.plugins.push(new webpack.IgnorePlugin(/moment/, /pikaday/));

  return config;
};
