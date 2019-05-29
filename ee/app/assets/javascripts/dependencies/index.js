import Vue from 'vue';
import DependenciesApp from './components/app.vue';
import createStore from './store';

export default () => {
  const el = document.querySelector('#js-dependencies-app');
  const { endpoint } = el.dataset;

  const store = createStore();

  return new Vue({
    el,
    store,
    components: {
      DependenciesApp,
    },
    render(createElement) {
      return createElement(DependenciesApp, {
        props: {
          endpoint,
        },
      });
    },
  });
};
