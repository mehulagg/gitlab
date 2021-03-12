import Vue from 'vue';
import App from './components/top_nav_app.vue';
// TODO: Move to BE for data-driven
import FAKE_DATA from './fake_data.json';

export const mountTopNav = (el) => {
  // We can read el.dataset
  return new Vue({
    el,
    render(h) {
      return h(App, {
        props: {
          navData: FAKE_DATA,
        },
      });
    },
  });
};
