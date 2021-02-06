import Vue from 'vue';
import { parseBoolean } from '~/lib/utils/common_utils';
// import ForkGroupsList from './components/fork_groups_list.vue';
import ForkForm from './components/fork_form.vue';

document.addEventListener('DOMContentLoaded', () => {
  const mountElement = document.getElementById('fork-groups-mount-element');

  const {
    endpoint,
    canCreateProject,
    newGroupPath,
    projectName,
    projectPath,
    projectDescription,
    projectVisibility,
  } = mountElement.dataset;

  const hasReachedProjectLimit = !parseBoolean(canCreateProject);

  return new Vue({
    el: mountElement,
    render(h) {
      return h(ForkForm, {
        props: {
          endpoint,
          hasReachedProjectLimit,
          newGroupPath,
          projectName,
          projectPath,
          projectDescription,
          projectVisibility,
        },
      });
    },
  });
});
