import Vue from 'vue';
import createStore from './stores';
import mergeRequestApprovalSettingsModule from './stores/modules/merge_request_approval_settings';
import MergeRequestApprovalSetting from './components/merge_request_approval_settings.vue';

const createMergeRequestApprovalSettingApp = (el) => {
  if (!el) {
    return false;
  }

  const store = createStore(mergeRequestApprovalSettingsModule());
  const { endpoint } = el.dataset;

  return new Vue({
    el,
    store,
    render: (createElement) =>
      createElement(MergeRequestApprovalSetting, {
        props: {
          endpoint,
        },
      }),
  });
};

export { createMergeRequestApprovalSettingApp };
