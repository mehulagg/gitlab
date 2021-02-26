import Vue from 'vue';
import App from './components/app.vue';
import ForkGroupsList from './components/fork_groups_list.vue';

document.addEventListener('DOMContentLoaded', () => {
  const mountElement = document.getElementById('fork-groups-mount-element');

  if (gon.features.forkProjectForm) {
    const {
      forkIllustration,
      endpoint,
      newGroupPath,
      projectFullPath,
      visibilityHelpPath,
      projectId,
      projectName,
      projectPath,
      projectDescription,
      projectVisibility,
    } = mountElement.dataset;

    return new Vue({
      el: mountElement,
      render(h) {
        return h(App, {
          props: {
            forkIllustration,
            endpoint,
            newGroupPath,
            projectFullPath,
            visibilityHelpPath,
            projectId,
            projectName,
            projectPath,
            projectDescription,
            projectVisibility,
          },
        });
      },
    });
  }

  const { endpoint } = mountElement.dataset;

  return new Vue({
    el: mountElement,
    render(h) {
      return h(ForkGroupsList, {
        props: {
          endpoint,
        },
      });
    },
  });
});
