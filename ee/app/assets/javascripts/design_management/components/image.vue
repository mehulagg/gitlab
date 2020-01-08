<script>
import _ from 'underscore';

export default {
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
    scale: {
      type: Number,
      required: false,
      default: 1,
    },
  },
  data() {
    return {
      defaultImageSize: null,
      imageStyle: {},
    };
  },
  watch: {
    scale(val) {
      if (val === 1) {
        this.resetImageSize();
      } else {
        this.zoom(val);
      }
    },
  },
  beforeDestroy() {
    window.removeEventListener('resize', this.resizeThrottled, false);
  },
  mounted() {
    this.onImgLoad();
    this.resizeThrottled = _.throttle(() => {
      const { contentImg } = this.$refs;
      if (!contentImg) return;
      const val = {
        height: contentImg.offsetHeight,
        width: contentImg.offsetWidth,
      };
      this.$emit('resized', val);
    }, 400);
    window.addEventListener('resize', this.resizeThrottled, false);
  },
  methods: {
    onImgLoad() {
      requestIdleCallback(this.setDefaultImageSize, { timeout: 1000 });
    },
    setImageSize({ width, height }) {
      this.imageStyle = {
        maxWidth: 'unset',
        width: `${width}px`,
        height: `${height}px`,
      };
      this.$emit('resized', { width, height });
    },
    zoom(amount) {
      const width = this.defaultImageSize.width * amount;
      const height = this.defaultImageSize.height * amount;
      this.setImageSize({ width, height });
    },
    resetImageSize() {
      this.setDefaultImageSize({ force: true });
    },
    setDefaultImageSize({ force }) {
      if (this.defaultImageSize && this.defaultImageSize.width > 0 && !force) return;

      const { contentImg } = this.$refs;
      if (!contentImg) return;

      this.imageStyle = {};
      this.$nextTick(() => {
        this.defaultImageSize = {
          height: contentImg.offsetHeight,
          width: contentImg.offsetWidth,
        };

        this.$emit('resized', this.defaultImageSize);
      });
    },
  },
};
</script>

<template>
  <div class="design-image-container js-design-image">
    <img
      ref="contentImg"
      :src="image"
      :alt="name"
      :style="imageStyle"
      class="img-fluid design-image js-design-image"
      @load="onImgLoad"
    />
  </div>
</template>
