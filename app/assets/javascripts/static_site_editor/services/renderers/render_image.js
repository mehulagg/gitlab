import { isAbsolute, getBaseURL, joinPaths } from '~/lib/utils/url_utility';

const canRender = ({ type }) => type === 'image';

let metadata;

const generateSourceDirectory = ({ source, target }, basePath) => {
  const hasTarget = target !== '';

  if (hasTarget && basePath.includes(target)) {
    return source;
  }

  return joinPaths(source, basePath);
};

const getSrc = originalSrc => {
  const rePath = /^(.+)\/([^/]+)$/; // Extracts the base path and fileName from an image path
  const [, basePath, fileName] = rePath.exec(originalSrc);
  let sourceDir = '';

  metadata.mounts.forEach(mount => {
    sourceDir = generateSourceDirectory(mount, basePath);
  });

  return joinPaths(getBaseURL(), metadata.project, '/-/raw/', metadata.branch, sourceDir, fileName);
};

const render = ({ destination: originalSrc, firstChild }, { skipChildren }) => {
  skipChildren();

  return {
    type: 'openTag',
    tagName: 'img',
    selfClose: true,
    attributes: {
      'data-original-src': !isAbsolute(originalSrc) ? originalSrc : '',
      src: isAbsolute(originalSrc) ? originalSrc : getSrc(originalSrc),
      alt: firstChild.literal,
    },
  };
};

const build = (mounts, project, branch) => {
  metadata = { mounts, project, branch };
  return { canRender, render };
};

export default { build };
