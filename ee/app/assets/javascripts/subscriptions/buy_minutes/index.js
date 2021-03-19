import Vue from 'vue';
import App from './components/app.vue';

export default () => {
  const el = document.getElementById('js-buy-minutes');

  return new Vue({
    el,
    components: {
      App,
    },
    render(createElement) {
      return createElement(App);
    },
  });
};
