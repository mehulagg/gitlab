import { startIde } from '~/ide/index';

function extraInitialData() {
  // This is empty now, but it will be used in: https://gitlab.com/gitlab-org/gitlab-ee/issues/5426
  return {};
}

startIde({
  extraInitialData,
});
