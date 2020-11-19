export const HELP_PAGE_BASE_URL = 'https://docs.gitlab.com/ee/';

const sanitizeHelpPath = path => {
  // strip '/' prefix
  let sanitizedPath = path[0] === '/' ? path.slice(1) : `${path}`;

  // strip invalid trailing patterns
  ['/', '.md', '.html'].forEach(invalidSuffix => {
    sanitizedPath = sanitizedPath.endsWith(invalidSuffix)
      ? sanitizedPath.slice(0, sanitizedPath.length - invalidSuffix.length)
      : sanitizedPath;
  });

  return sanitizedPath;
};

/**
 * Generate link to a GitLab documentation page
 * @param {String} path - path to doc file relative to the doc/ directory in the GitLab repository
 *
 */
export const helpPagePath = (path, { anchor = '' } = {}) => {
  const helpPageUrl = new URL(`${HELP_PAGE_BASE_URL}${sanitizeHelpPath(path)}`);
  helpPageUrl.hash = anchor;

  return helpPageUrl.toString();
};
