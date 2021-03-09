import Vue from 'vue';
import { parseBoolean } from '~/lib/utils/common_utils';
import createRouter from '~/repository/router';
import UploadButton from './details/upload_button.vue';

export const initUploadFileTrigger = () => {
  const uploadFileTriggerEl = document.querySelector('.js-upload-file-experiment-trigger');

  if (!uploadFileTriggerEl) return false;

  const {
    targetBranch,
    origionalBranch,
    canPushCode,
    path,
    projectPath,
  } = uploadFileTriggerEl.dataset;

  return new Vue({
    el: uploadFileTriggerEl,
    router: createRouter(projectPath, origionalBranch),
    provide: {
      targetBranch,
      origionalBranch,
      canPushCode: parseBoolean(canPushCode),
      path,
      projectPath,
    },
    render(h) {
      return h(UploadButton);
    },
  });
};
