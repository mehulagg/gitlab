<script>
import _ from 'lodash-es';
import { GlLoadingIcon } from '@gitlab/ui';

export default {
  components: {
    GlLoadingIcon,
  },
  props: {
    image: {
      type: String,
      required: false,
      default: '',
    },
    name: {
      type: String,
      required: false,
      default: '',
    },
  },
  beforeDestroy() {
    window.removeEventListener('resize', this.resizeThrottled, false);
  },
  mounted() {
    this.onImgLoad();
    this.resizeThrottled = _.throttle(this.onImgLoad, 400);
    window.addEventListener('resize', this.resizeThrottled, false);
  },
  methods: {
    onImgLoad() {
      requestIdleCallback(this.calculateImgSize, { timeout: 1000 });
    },
    calculateImgSize() {
      const { contentImg } = this.$refs;

      if (!contentImg) return;

      this.$nextTick(() => {
        const naturalRatio = contentImg.naturalWidth / contentImg.naturalHeight;
        const visibleRatio = contentImg.width / contentImg.height;

        const position = {
          // Handling the case where img element takes more width than visible image thanks to object-fit: contain
          width:
            naturalRatio < visibleRatio
              ? contentImg.clientHeight * naturalRatio
              : contentImg.clientWidth,
          height: contentImg.clientHeight,
        };

        this.$emit('setOverlayDimensions', position);
      });
    },
  },
};
</script>

<template>
  <div class="d-flex align-items-center h-100 w-100 p-3 overflow-hidden js-design-image">
    <img
      ref="contentImg"
      :src="image"
      :alt="name"
      class="ml-auto mr-auto img-fluid mh-100 design-image"
      @load="onImgLoad"
    />
  </div>
</template>
