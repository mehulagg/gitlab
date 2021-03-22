import Vue from 'vue';
import GlCountdown from '~/vue_shared/components/gl_countdown.vue';
import initJobsTable from '~/jobs/components/table';

if (gon.features?.jobsTableVue) {
  initJobsTable();
} else {
  const remainingTimeElements = document.querySelectorAll('.js-remaining-time');

  remainingTimeElements.forEach(
    (el) =>
      new Vue({
        el,
        render(h) {
          return h(GlCountdown, {
            props: {
              endDateString: el.dateTime,
            },
          });
        },
      }),
  );
}
