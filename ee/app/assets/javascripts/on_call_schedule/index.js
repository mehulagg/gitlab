import Vue from 'vue';
import OnCallScheduleWrapper from './components/on_call_schedule_wrapper.vue';

export default () => {
  const el = document.querySelector('#js-on_call_schedule');

  if (!el) return null;

  const {emptyOnCallScheduleSvgPath} = el.dataset;

  return new Vue({
    el,
    provide: {
      emptyOnCallScheduleSvgPath,
    },
    render(createElement) {
      return createElement(OnCallScheduleWrapper);
    },
  });
};
