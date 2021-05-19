<script>
import { contentTop } from '~/lib/utils/common_utils';

export default {
  data() {
    return {
      heightFromTop: '40px', // default header height
    };
  },
  mounted() {
    this.observeHeaderChange();
  },
  methods: {
    observeHeaderChange() {
      const ob = new MutationObserver(() => {
        const target = document.querySelector('#js-peek');

        if (document.body.contains(target)) {
          ob.disconnect();

          this.heightFromTop = `${contentTop()}px`;
        }
      });

      ob.observe(document.body, { childList: true });
    },
  },
};
</script>

<template>
  <div>
    <slot :height-from-top="heightFromTop"></slot>
  </div>
</template>
