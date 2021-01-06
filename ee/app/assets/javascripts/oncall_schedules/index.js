import Vue from 'vue';
import VueApollo from 'vue-apollo';
import OnCallSchedulesWrapper from './components/oncall_schedules_wrapper.vue';
import apolloProvider from './graphql';

Vue.use(VueApollo);

export default () => {
  const el = document.querySelector('#js-oncall_schedule');

  if (!el) return null;

  const { projectPath, emptyOncallSchedulesSvgPath, timezones } = el.dataset;



  apolloProvider.clients.defaultClient.cache.writeData({
    data: {
      shiftTimeUnitWidth: 0,
    },
  });

  return new Vue({
    el,
    apolloProvider,
    provide: {
      projectPath,
      emptyOncallSchedulesSvgPath,
      timezones: JSON.parse(timezones),
    },
    render(createElement) {
      return createElement(OnCallSchedulesWrapper);
    },
  });
};
