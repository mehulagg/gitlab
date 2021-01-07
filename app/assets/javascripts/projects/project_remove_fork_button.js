import Vue from 'vue';
import ProjectRemoveForkButton from './components/project_remove_fork_button.vue';

export default (selector = '#js-project-remove-fork-button') => {
  const el = document.querySelector(selector);

  if (!el) return;

  const { confirmPhrase, formPath } = el.dataset;

  // eslint-disable-next-line no-new
  new Vue({
    el,
    render(createElement) {
      return createElement(ProjectRemoveForkButton, {
        props: {
          confirmPhrase,
          formPath,
        },
      });
    },
  });
};
