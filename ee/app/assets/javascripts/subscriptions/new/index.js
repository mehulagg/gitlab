import Vue from 'vue';
import App from './components/app.vue';
import createStore from './store';

export default () => {
  const el = document.getElementById('js-new-subscription');
  const store = createStore(el.dataset);

  return new Vue({
    el,
    store,
    components: {
      App,
    },
    render(createElement) {
      return createElement(App);
    },
  });
};
