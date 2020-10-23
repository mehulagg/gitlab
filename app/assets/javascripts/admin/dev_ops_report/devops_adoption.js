import Vue from 'vue';
import DevopsAdoptionApp from './components/devops_adoption_app.vue';

export default () => {
  const el = document.querySelector('.js-devops-adoption');

  if (!el) return false;

  return new Vue({
    el,
    render(h) {
      return h(DevopsAdoptionApp);
    },
  });
};
