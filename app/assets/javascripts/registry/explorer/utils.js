export const dockerBuildCommand = ({ repositoryUrl }) => {
  // eslint-disable-next-line @gitlab/require-i18n-strings
  return `docker build -t ${repositoryUrl} .`;
};

export const dockerPushCommand = ({ repositoryUrl }) => {
  // eslint-disable-next-line @gitlab/require-i18n-strings
  return `docker push ${repositoryUrl}`;
};

export const dockerLoginCommand = ({ registryHostUrlWithPort }) => {
  // eslint-disable-next-line @gitlab/require-i18n-strings
  return `docker login ${registryHostUrlWithPort}`;
};
