import Vue from 'vue';
import ProjectAdjournedDeleteButton from './components/project_adjourned_delete_button.vue';

export default (selector = '#js-project-adjourned-delete-button') => {
  const el = document.querySelector(selector);

  if (!el) return;

  const { adjournedRemovalDate, confirmPhrase, formPath, recoveryHelpPath } = el.dataset;

  // eslint-disable-next-line no-new
  new Vue({
    el,
    render(createElement) {
      return createElement(ProjectAdjournedDeleteButton, {
        props: {
          adjournedRemovalDate,
          confirmPhrase,
          formPath,
          recoveryHelpPath,
        },
      });
    },
  });
};
