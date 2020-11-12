import Vue from 'vue';
import AppliedLabels from './components/applied_labels.vue';

export default () => {
  const targetEl = '.js-applied-labels';
  const parentEl = '.js-applied-labels-parent';
  const el = document.querySelector(targetEl);

  const { selectedLabels = [], labels: labelsPath } = el.dataset;

  const parent = el.closest(parentEl);

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
            targetParent: parent,
            selectedLabels: selectedLabels.map(({ id }) => id),
            labelsPath,
          },
        });
      },
    });
  }
};
