import Vue from 'vue';
import SecurityPoliciesListApp from './components/security_policies_list/app.vue';

export default () => {
  const el = document.querySelector('#js-security-policies-list');
  const { documentationPath, project, selectProjectPath } = el.dataset;

  return new Vue({
    el,
    provide: {
      documentationPath,
    },
    render(createElement) {
      return createElement(SecurityPoliciesListApp, {
        props: {
          project,
          selectProjectPath,
        },
      });
    },
  });
};
