<script>
import { contentTop } from '~/lib/utils/common_utils';

export default {
  data() {
    return {
      heightFromTop: `${contentTop()}px`, // default header height
      ob: {},
    };
  },
  mounted() {
    this.observeHeaderChange();
  },
  destroyed() {
    this.ob?.disconnect();
  },
  methods: {
    observeHeaderChange() {
      this.ob = new MutationObserver(() => {
        const target = document.querySelector('#js-peek');
        if (document.body.contains(target)) {
          this.ob.disconnect();

          this.heightFromTop = `${contentTop()}px`;
        }
      });

      this.ob.observe(document.body, { childList: true });
    },
  },
};
</script>

<template>
  <div>
    <slot :height-from-top="heightFromTop"></slot>
  </div>
</template>
