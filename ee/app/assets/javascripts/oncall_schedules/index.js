import Vue from 'vue';
import OnCallSchedulesWrapper from './components/oncall_schedules_wrapper.vue';

export default () => {
  const el = document.querySelector('#js-oncall_schedule');

  if (!el) return null;

  const { emptyOncallSchedulesSvgPath, timezones } = el.dataset;

  return new Vue({
    el,
    provide: {
      timezones: JSON.parse(timezones),
      emptyOncallSchedulesSvgPath,
    },
    render(createElement) {
      return createElement(OnCallSchedulesWrapper);
    },
  });
};
