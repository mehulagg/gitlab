import Vue from 'vue';
import Translate from '~/vue_shared/translate';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import ProjectFilter from './components/project_filter.vue';

Vue.use(Translate);

export default store => {
  let initialProject;
  const el = document.getElementById('js-search-project-dropdown');

  const { initialProjectData } = el.dataset;

  initialProject = JSON.parse(initialProjectData);
  initialProject = convertObjectPropsToCamelCase(initialProject, { deep: true });

  return new Vue({
    el,
    store,
    render(createElement) {
      return createElement(ProjectFilter, {
        props: {
          initialProject,
        },
      });
    },
  });
};
