/* eslint-disable import/no-commonjs, import/no-extraneous-dependencies, @gitlab/require-i18n-strings, no-console */

const fs = require('fs');
const path = require('path');
const process = require('process');

const SPROCKETS_MANIFEST_FILENAME_PREFIX = '.sprockets-manifest';

const railsAssetsDir = path.resolve(__dirname, '../../', 'public/assets/');

// cache
let sprocketsManifest;
let railsAssetResolutions;

const findSprocketsManifest = () => {
  // use cached version if available
  if (sprocketsManifest) {
    return sprocketsManifest;
  }
  try {
    const files = fs.readdirSync(railsAssetsDir);
    const manifestFile = path.resolve(
      railsAssetsDir,
      files.find((f) => f.startsWith(SPROCKETS_MANIFEST_FILENAME_PREFIX)),
    );

    sprocketsManifest = JSON.parse(fs.readFileSync(manifestFile));
  } catch {
    console.error(
      '\n\nSprockets manifest file not found. Have you precompiled assets in the main gitlab directory?\n\n',
    );
    process.exit(1);
  }

  return sprocketsManifest;
};

/**
 * Build map of [filename]: [rails asset filename]
 */
const buildRailsAssetResolutions = () => {
  if (railsAssetResolutions) {
    return;
  }

  const manifest = findSprocketsManifest();
  railsAssetResolutions = Object.keys(manifest.files).reduce((resolutions, key) => {
    Object.assign(resolutions, { [manifest.files[key].logical_path]: key });
    return resolutions;
  }, {});
};

exports.resolveRailsAsset = (filename) => {
  buildRailsAssetResolutions();

  const resolvedFilename = railsAssetResolutions[filename];
  if (!resolvedFilename) {
    console.error(
      `\n\nAsset not found - [${resolvedFilename}]. Have you precompiled assets in the main gitlab directory?\n\n`,
    );
    process.exit(1);
  }

  return path.resolve(railsAssetsDir, resolvedFilename);
};
