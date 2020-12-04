import Vue from 'vue';
import KeepLatestArtifactCheckbox from '~/artifacts_settings/keep_latest_artifact_checkbox.vue';

export default (containerId = 'js-artifacts-settings-app') => {
  const containerEl = document.getElementById(containerId);

  return new Vue({
    el: containerEl,
    render(createElement) {
      return createElement(KeepLatestArtifactCheckbox);
    },
  });
};
