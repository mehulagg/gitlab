const { memoize } = require('lodash');
const { OUTPUTS } = require('./constants');
const { getCSSPath } = require('./get_css_path');
const { getStartupCSS } = require('./get_startup_css');
const { log } = require('./utils');
const { writeStartupSCSS } = require('./write_startup_scss');

const memoizedCSSPath = memoize(getCSSPath);

const main = async () => {
  const tasks = OUTPUTS.map(async ({ outFile, htmlPaths, cssKeys, purgeOptions = {} }) => {
    log(`Generating startup CSS for HTML files: ${htmlPaths}`);
    const generalCSS = await getStartupCSS({
      htmlPaths,
      cssPaths: cssKeys.map(memoizedCSSPath),
      purgeOptions,
    });

    log(`Writing to startup CSS...`);
    const startupCSSPath = writeStartupSCSS(outFile, generalCSS);
    log(`Finished writing to ${startupCSSPath}`);
  });

  await Promise.all(tasks);
};

main();
