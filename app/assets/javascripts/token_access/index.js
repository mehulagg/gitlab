import Vue from 'vue';
import TokenAccess from './components/token_access.vue';

const mountTokenAccessApp = (containerEl) => {
  return new Vue({
    el: containerEl,
    render(createElement) {
      return createElement(TokenAccess);
    },
  });
};

export default (containerId = 'js-ci-token-access-app') => {
  const el = document.getElementById(containerId);

  return !el ? {} : mountTokenAccessApp(el);
};
