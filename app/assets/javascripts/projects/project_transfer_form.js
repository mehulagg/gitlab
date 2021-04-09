import Vue from 'vue';
import ProjectTransferForm from './components/project_transfer_form.vue';

export default (selector = '#js-project-transfer-form') => {
  const el = document.querySelector(selector);

  if (!el) return;

  const { confirmPhrase, formPath, namespaceOptions } = el.dataset;

  // eslint-disable-next-line no-new
  new Vue({
    el,
    render(createElement) {
      return createElement(ProjectTransferForm, {
        props: {
          confirmPhrase,
          formPath,
          namespaceOptions,
        },
      });
    },
  });
};
