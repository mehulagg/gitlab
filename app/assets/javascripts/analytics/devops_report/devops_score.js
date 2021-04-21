import Vue from 'vue';
import DevopsScore from './components/devops_score.vue';

export default () => {
  const el = document.getElementById('js-devops-score');

  if (!el) return false;

  const { averageScore, createdAt, cards } = el.dataset;

  return new Vue({
    el,
    provide: {
      createdAt,
      cards,
      averageScore,
    },
    render(h) {
      return h(DevopsScore);
    },
  });
};
