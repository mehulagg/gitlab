import Vue from 'vue';
import OnCallSchedulesWrapper from './components/oncall_schedules_wrapper.vue';

export default () => {
  const el = document.querySelector('#js-oncall_schedule');

  if (!el) return null;

  const { emptyOncallSchedulesSvgPath } = el.dataset;

  return new Vue({
    el,
    provide: {
      emptyOncallSchedulesSvgPath,
    },
    render(createElement) {
      return createElement(OnCallSchedulesWrapper);
    },
  });
};
