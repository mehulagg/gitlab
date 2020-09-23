import Vue from 'vue';
import EnvironmentDashboardComponent from 'ee/environments_dashboard/components/dashboard/dashboard.vue';
import createStore from 'ee/vue_shared/dashboards/store';

document.addEventListener(
  'DOMContentLoaded',
  () =>
    new Vue({
      el: '#js-environments',
      store: createStore(),
      components: {
        EnvironmentDashboardComponent,
      },
      render(createElement) {
        return createElement(EnvironmentDashboardComponent, {
          props: this.$el.dataset,
        });
      },
    }),
);
