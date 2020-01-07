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
      initialImageSize: null,
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
    imageSize(val) {
      this.$emit('resized', val);
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
      requestIdleCallback(this.setInitialImageSize, { timeout: 1000 });
    },
    setImageSize({ width, height }) {
      this.imageStyle = {
        maxWidth: 'unset',
        width: `${width}px`,
        height: `${height}px`,
      };
    },
    zoom(amount) {
      const width = this.initialImageSize.width * amount;
      const height = this.initialImageSize.height * amount;
      this.setImageSize({ width, height });
    },
    resetImageSize() {
      this.setImageSize(this.initialImageSize);
    },
    setInitialImageSize() {
      if (this.initialImageSize && this.initialImageSize.width > 0) return;

      const { contentImg } = this.$refs;
      if (!contentImg) return;

      this.$nextTick(() => {
        this.initialImageSize = {
          height: contentImg.offsetHeight,
          width: contentImg.offsetWidth,
        };
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
