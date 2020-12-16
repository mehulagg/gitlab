export function getDerivedMergeRequestInformation({ endpoint } = {}) {
  const mrPath = endpoint
    .replace(/^\//, '')
    .split('/')
    .slice(0, -1);
  const [userOrGroup, project, , , id] = mrPath;

  return {
    mrPath: mrPath.join('/'),
    userOrGroup,
    project,
    id,
  };
}
