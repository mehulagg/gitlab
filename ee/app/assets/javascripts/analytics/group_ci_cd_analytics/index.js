import Vue from 'vue';
import CiCdAnalyticsApp from './components/app.vue';

export default () => {
  const el = document.querySelector('#js-group-ci-cd-analytics-app');

  if (!el) return false;

  return new Vue({
    el,
    render: createElement => createElement(CiCdAnalyticsApp),
  });
};
