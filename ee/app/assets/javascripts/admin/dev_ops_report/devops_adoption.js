import Vue from 'vue';
import DevopsAdoptionApp from './components/devops_adoption_app.vue';
import apolloProvider from './graphql';

export default () => {
  const el = document.querySelector('.js-devops-adoption');

  if (!el) return false;

  const { emptyStateSvgPath } = el.dataset;

  return new Vue({
    el,
    apolloProvider,
    provide: {
      emptyStateSvgPath,
    },
    render(h) {
      return h(DevopsAdoptionApp);
    },
  });
};
