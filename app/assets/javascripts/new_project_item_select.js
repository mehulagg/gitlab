import Vue from 'vue';
import NewProjectItemSelect from '~/vue_shared/components/new_project_item_select.vue';

import * as UserApi from '~/api/user_api';

export default () => {
  const el = document.getElementById('js-new-project-item-select');
  const userFrequentProjects = JSON.parse(localStorage.getItem(`${gon.current_username}/frequent-projects`)); 

  return new Vue({
    el,
    render(createElement) {
      return createElement(NewProjectItemSelect, {
        props: {
          path: el.dataset.path,
          label: el.dataset.label,
          with_feature_enabled: el.dataset.with_feature_enabled,
          type: el.dataset.type,
          frequentProjects: userFrequentProjects
        },
      });
    },
  });
};
