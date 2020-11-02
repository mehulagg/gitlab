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

const getSrc = destination => {
  const rePath = /^(.+)\/([^/]+)$/; // Extracts the base path anf fileName of the image
  const [, basePath, fileName] = rePath.exec(destination);
  let sourceDir = '';

  metadata.mounts.forEach(mount => {
    sourceDir = generateSourceDirectory(mount, basePath);
  });

  return joinPaths(getBaseURL(), metadata.project, '/-/raw/', metadata.branch, sourceDir, fileName);
};

const render = ({ destination, firstChild }, { skipChildren }) => {
  skipChildren();

  return {
    type: 'openTag',
    tagName: 'img',
    selfClose: true,
    attributes: {
      src: isAbsolute(destination) ? destination : getSrc(destination),
      alt: firstChild.literal,
    },
  };
};

const build = (mounts, project, branch) => {
  metadata = { mounts, project, branch };
  return { canRender, render };
};

export default { build };
