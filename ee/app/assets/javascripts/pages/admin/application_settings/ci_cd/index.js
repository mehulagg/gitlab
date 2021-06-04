import Vue from 'vue';
import CiTemplateDropdown from './ci_template_dropdown.vue';

const el = document.querySelector('.js-ci-template-dropdown');
const { gitlabCiYmls } = el.dataset;

// eslint-disable-next-line no-new
new Vue({
  el,
  render(createElement) {
    return createElement(CiTemplateDropdown, {
      props: {
        gitlabCiYmls: JSON.parse(gitlabCiYmls),
      },
    });
  },
});
