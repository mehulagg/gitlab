const path = require('path');
const IS_EE = require('../../../config/helpers/is_ee_env');

// controls --------------------------------------------------------------------
const HTML_TO_REMOVE = [
  'style',
  'script',
  'link[rel="stylesheet"]',
  '.content-wrapper',
  '#js-peek',
  '.modal',
  '.feature-highlight',
];
const CSS_TO_REMOVE = [
  '.tooltip',
  '.tooltip.show',
  '.fa',
  '.gl-accessibility:focus',
  '.toasted-container',
  'body .toasted-container.bottom-left',
  '.popover',
  '.with-performance-bar .navbar-gitlab',
  '.text-secondary',
  /\.feature-highlight-popover-content/,
  /\.commit/,
  /\.md/,
  /\.with-performance-bar/,
  /\.identicon/,
];
const APPLICATION_CSS_PREFIX = 'application';
const APPLICATION_DARK_CSS_PREFIX = 'application_dark';
const UTILITIES_CSS_PREFIX = 'application_utilities';
const UTILITIES_DARK_CSS_PREFIX = 'application_utilities_dark';

// paths -----------------------------------------------------------------------
const ROOT = path.resolve(__dirname, '../../..');
const FIXTURES_ROOT = path.join(ROOT, 'tmp/tests/frontend', IS_EE ? 'fixtures-ee' : 'fixtures');
const PATH_SIGNIN_HTML = path.join(FIXTURES_ROOT, 'startup_css/sign-in.html');
const PATH_ASSETS = path.join(ROOT, 'tmp/startup_css_assets');
const PATH_STARTUP_SCSS = path.join(ROOT, 'app/assets/stylesheets/startup');
const OUTPUTS = [
  {
    outFile: 'startup-general',
    htmlPaths: [
      path.join(FIXTURES_ROOT, 'startup_css/project-general.html'),
      path.join(FIXTURES_ROOT, 'startup_css/project-general-legacy-menu.html'),
      path.join(FIXTURES_ROOT, 'startup_css/project-general-signed-out.html'),
    ],
    cssKeys: [APPLICATION_CSS_PREFIX, UTILITIES_CSS_PREFIX],
    purgeOptions: {},
  },
  {
    outFile: 'startup-dark',
    htmlPaths: [
      path.join(FIXTURES_ROOT, 'startup_css/project-dark.html'),
      path.join(FIXTURES_ROOT, 'startup_css/project-dark-legacy-menu.html'),
      path.join(FIXTURES_ROOT, 'startup_css/project-dark-signed-out.html'),
    ],
    cssKeys: [APPLICATION_DARK_CSS_PREFIX, UTILITIES_DARK_CSS_PREFIX],
    purgeOptions: {},
  },
  {
    outFile: 'startup-signin',
    htmlPaths: [PATH_SIGNIN_HTML],
    cssKeys: [APPLICATION_CSS_PREFIX, UTILITIES_CSS_PREFIX],
    purgeOptions: {
      safelist: {
        standard: ['fieldset'],
        deep: [/login-page$/],
      },
    },
  },
];

module.exports = {
  HTML_TO_REMOVE,
  CSS_TO_REMOVE,
  APPLICATION_CSS_PREFIX,
  APPLICATION_DARK_CSS_PREFIX,
  UTILITIES_CSS_PREFIX,
  UTILITIES_DARK_CSS_PREFIX,
  ROOT,
  PATH_ASSETS,
  PATH_STARTUP_SCSS,
  OUTPUTS,
};
