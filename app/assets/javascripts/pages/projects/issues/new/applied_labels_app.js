import Vue from 'vue';
import AppliedLabels from './components/applied_labels.vue';

export default () => {
  const el = document.getElementById('js-applied-labels');

  if (el) {
    // Find the label dropdown we want to target
    // pass it into the component
    // eslint-disable-next-line no-new
    new Vue({
      el,
      components: {
        AppliedLabels,
      },

      render(createElement) {
        return createElement(AppliedLabels, {
          props: {
            target: '.js-label-select',
          },
        });
      },
    });
  }
};
