import Vue from 'vue';
import OverrideDropdownApp from './app.vue';

export default (el, store) => {
  if (!el) {
    return null;
  }

  return new Vue({
    el,
    store,
    render(createElement) {
      return createElement(OverrideDropdownApp);
    },
  });
};
