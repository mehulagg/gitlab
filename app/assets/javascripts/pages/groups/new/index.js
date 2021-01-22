import $ from 'jquery';
import Vue from 'vue';
import BindInOut from '~/behaviors/bind_in_out';
import initFilePickers from '~/file_pickers';
import Group from '~/group';
import LinkedTabs from '~/lib/utils/bootstrap_linked_tabs';
import GroupPathValidator from './group_path_validator';
import Tabs from './group_tabs.vue';

const parentId = $('#group_parent_id');
if (!parentId.val()) {
  new GroupPathValidator(); // eslint-disable-line no-new
}
BindInOut.initAll();
initFilePickers();

new Group(); // eslint-disable-line no-new

// eslint-disable-next-line no-new
new Vue({
  el: document.querySelector('.js-gl-group-tabs'),
  render: (h) =>
    h(Tabs, {
      on: {
        input: (current) => {
          document.querySelectorAll('.gitlab-tab-content .tab-pane').forEach((el, index) => {
            if (current === index) {
              el.classList.add('active');
            } else {
              el.classList.remove('active');
            }
          });
        },
      },
    }),
});

const CONTAINER_SELECTOR = '.group-edit-container .nav-tabs';
const DEFAULT_ACTION = '#create-group-pane';
// eslint-disable-next-line no-new
new LinkedTabs({
  defaultAction: DEFAULT_ACTION,
  parentEl: CONTAINER_SELECTOR,
  hashedTabs: true,
});

if (window.location.hash) {
  $(CONTAINER_SELECTOR).find(`a[href="${window.location.hash}"]`).tab('show');
}
