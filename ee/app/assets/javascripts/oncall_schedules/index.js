import Vue from 'vue';
import VueApollo from 'vue-apollo';
import OnCallSchedulesWrapper from './components/oncall_schedules_wrapper.vue';
import createDefaultClient from '~/lib/graphql';

Vue.use(VueApollo);

export default () => {
  const el = document.querySelector('#js-oncall_schedule');

  if (!el) return null;

  const { projectPath, emptyOncallSchedulesSvgPath, timezones } = el.dataset;

  const apolloProvider = new VueApollo({
    defaultClient: createDefaultClient(),
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
