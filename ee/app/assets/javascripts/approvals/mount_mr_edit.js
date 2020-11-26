import Vue from 'vue';
import Vuex from 'vuex';
import { parseBoolean } from '~/lib/utils/common_utils';
import createStore from './stores';
import mrEditModule from './stores/modules/mr_edit';
import MrEditApp from './components/mr_edit/app.vue';

Vue.use(Vuex);

export default function mountApprovalInput(el) {
  if (!el) {
    return null;
  }

  const targetBranch =
    document.querySelector('#js-target-branch-title')?.textContent ||
    document.querySelector('#merge_request_target_branch')?.value;

  const store = createStore(mrEditModule(), {
    ...el.dataset,
    prefix: 'mr-edit',
    canEdit: parseBoolean(el.dataset.canEdit),
    allowMultiRule: parseBoolean(el.dataset.allowMultiRule),
  });

  store.dispatch('setTargetBranch', targetBranch);

  return new Vue({
    el,
    store,
    render(h) {
      return h(MrEditApp);
    },
  });
}
