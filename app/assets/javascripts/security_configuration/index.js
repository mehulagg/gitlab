import Vue from 'vue';
import { parseBooleanDataAttributes } from '~/lib/utils/dom_utils';
import SecurityConfigurationApp from './components/app.vue';

export default function init() {
  const el = document.getElementById('js-security-configuration');

  return new Vue({
    el,
    render(createElement) {
      return createElement(SecurityConfigurationApp);
    },
  });
}
