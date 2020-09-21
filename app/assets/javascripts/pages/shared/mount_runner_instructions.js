import Vue from 'vue';
import InstallRunnerInstructions from '~/vue_shared/components/runner_instructions/runner_instructions.vue';
import { createStore } from '~/vue_shared/components/runner_instructions/store';

export function initInstallRunner() {
  const installRunnerEl = document.getElementById('js-install-runner');

  if (installRunnerEl) {
    // eslint-disable-next-line no-new
    new Vue({
      el: installRunnerEl,
      store: createStore({
        ...installRunnerEl.dataset,
      }),
      render(createElement) {
        return createElement(InstallRunnerInstructions);
      },
    });
  }
}
