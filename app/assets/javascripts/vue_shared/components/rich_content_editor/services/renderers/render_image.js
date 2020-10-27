const canRender = ({ type }) => type === 'image';

// NOTE: the `mounts` and `project` metadata is not used yet, but will be used in a follow-up iteration
// eslint-disable-next-line no-unused-vars
const render = (node, { skipChildren }, { mounts, project }) => {
  skipChildren();

  // TODO resolve relative paths

  return {
    type: 'openTag',
    tagName: 'img',
    selfClose: true,
    attributes: {
      src: node.destination,
      alt: node.firstChild.literal,
    },
  };
};

export default { canRender, render };
