import Vue from 'vue';
import { parseBooleanDataAttributes } from '~/lib/utils/dom_utils';
import SecurityConfigurationApp from './components/app.vue';

export const initSecurityConfiguration = (el) => {
  if (!el) {
    return null;
  }

  return new Vue({
    el,
    render(createElement) {
      return createElement(SecurityConfigurationApp);
    },
  });
}
