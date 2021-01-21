import Vue from 'vue';
import BlockingMrInput from 'ee/projects/merge_requests/blocking_mr_input_root.vue';
import { n__ } from '~/locale';

export default (el) => {
  if (!el) {
    return null;
  }
  const { hiddenBlockingMrsCount, visibleBlockingMrRefs } = el.dataset;
  const parsedVisibleBlockingMrRefs = JSON.parse(visibleBlockingMrRefs);
  const containsHiddenBlockingMrs = hiddenBlockingMrsCount > 0;

  const references = containsHiddenBlockingMrs
    ? [
        ...parsedVisibleBlockingMrRefs,
        {
          text: n__(
            '%d inaccessible merge request',
            '%d inaccessible merge requests',
            hiddenBlockingMrsCount,
          ),
          isHiddenRef: true,
        },
      ]
    : parsedVisibleBlockingMrRefs;

  return new Vue({
    el,
    render(h) {
      return h(BlockingMrInput, {
        props: {
          existingRefs: references,
          containsHiddenBlockingMrs,
        },
      });
    },
  });
};
