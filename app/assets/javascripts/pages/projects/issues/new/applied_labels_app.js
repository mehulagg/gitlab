import Vue from 'vue';
import AppliedLabels from './components/applied_labels.vue';

console.log('AppliedLabels');
export default () => {
  console.log('INITING');
  const targetEl = '.js-applied-labels';
  const parentEl = '.js-applied-labels-parent';
  const el = document.querySelector(targetEl);

  const { labels = [], selectedLabels = [] } = el.dataset;

  const parent = el.closest(parentEl);

  console.log('parentEl', parentEl);
  console.log('targetEl', targetEl);
  console.log('el', el);
  console.log('parent', parent);

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
            labels,
          },
        });
      },
    });
  }
};
