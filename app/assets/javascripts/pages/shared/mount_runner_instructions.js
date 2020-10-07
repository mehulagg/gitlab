/* eslint-disable @gitlab/require-i18n-strings */
import Vue from 'vue';
import VueApollo from 'vue-apollo';
import createDefaultClient from '~/lib/graphql';
import InstallRunnerInstructions from '~/vue_shared/components/runner_instructions/runner_instructions.vue';

Vue.use(VueApollo);

export function initInstallRunner() {
  const installRunnerEl = document.getElementById('js-install-runner');
  // const { instructionsPath } = installRunnerEl.dataset || {};

  if (installRunnerEl) {
    const defaultClient = createDefaultClient({
      Query: {
        platform() {
          return [
            {
              name: 'linux',
              humanReadableName: 'Linux',
              architectures: [
                {
                  name: '386',
                  downloadLocation:
                    'https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-386',
                  installationInstructions: 'installation...',
                  registerInstructions: 'registration...',
                  __typename: 'architecture',
                },
                {
                  name: 'amd64',
                  downloadLocation:
                    'https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-386',
                  installationInstructions: 'installation...',
                  registerInstructions: 'registration...',
                  __typename: 'architecture',
                },
                {
                  name: 'arm',
                  downloadLocation:
                    'https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-386',
                  installationInstructions: 'installation...',
                  registerInstructions: 'registration...',
                  __typename: 'architecture',
                },
                {
                  name: 'arm64',
                  downloadLocation:
                    'https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-386',
                  installationInstructions: 'installation...',
                  registerInstructions: 'registration...',
                  __typename: 'architecture',
                },
              ],
              __typename: 'Platform',
            },
            {
              name: 'windows',
              humanReadableName: 'Windows',
              architectures: [
                {
                  name: '386',
                  downloadLocation:
                    'https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-windows-386.exe',
                  installationInstructions: 'installation...',
                  registerInstructions: 'registration...',
                  __typename: 'architecture',
                },
              ],
              __typename: 'Platform',
            },
          ];
        },
      },
    });

    const apolloProvider = new VueApollo({
      defaultClient,
    });

    // eslint-disable-next-line no-new
    new Vue({
      el: installRunnerEl,
      apolloProvider,
      provide: {
        instructionsPath: '/',
      },
      // store: createStore({
      //   ...installRunnerEl.dataset,
      // }),
      render(createElement) {
        return createElement(InstallRunnerInstructions);
      },
    });
  }
}
