const fs = require('fs');
const cheerio = require('cheerio');
const path = require('path');

const THINGS_TO_REMOVE = [
  'script',
  'link[rel="stylesheet"]',
  '.content-wrapper',
  '#js-peek',
  '.modal',
  '.dropdown-menu',
  '.feature-highlight',
  '.fa-spin',
];

const ROOT = path.resolve(__dirname, '../../..');
const GENERAL_HTML_PATH = path.join(
  ROOT,
  'tmp/tests/frontend/fixtures-ee/startup_css/project-overview.html',
);

const main = () => {
  if (!fs.existsSync(GENERAL_HTML_PATH)) {
    console.log(`Could not find fixture "${GENERAL_HTML_PATH}". Have you run the fixtures?`);
    process.exit(1);
  }

  const html = fs.readFileSync(GENERAL_HTML_PATH);

  const $ = cheerio.load(html);

  THINGS_TO_REMOVE.forEach((selector) => {
    $(selector).remove();
  });

  const newHtml = $.html();

  fs.writeFileSync(
    path.join(path.dirname(GENERAL_HTML_PATH), 'project-overview-new.html'),
    newHtml,
  );
};

main();
