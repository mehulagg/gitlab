export default (refs, type) => {
  let fullName;

  return refs.map(ref => {
    if (type === 'branch') {
      fullName = `refs/heads/${ref}`;
    } else {
      fullName = `refs/tags/${ref}`;
    }

    return {
      shortName: ref,
      fullName,
    };
  });
};
