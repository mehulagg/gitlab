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
      baseImageSize: null,
      imageStyle: null,
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
      this.$emit('resize', val);
    }, 400);

    window.addEventListener('resize', this.resizeThrottled, false);
  },
  methods: {
    onImgLoad() {
      requestIdleCallback(this.resetImageSize, { timeout: 1000 });
    },
    onResize({ width, height }) {
      this.$emit('resize', { width, height });
    },
    zoom(amount) {
      const width = this.baseImageSize.width * amount;
      const height = this.baseImageSize.height * amount;
      this.imageStyle = {
        width: `${width}px`,
        height: `${height}px`,
      };

      this.onResize({ width, height });
    },
    resetImageSize() {
      const { contentImg } = this.$refs;
      if (!contentImg) return;

      this.imageStyle = null;
      this.$nextTick(() => {
        this.baseImageSize = {
          height: contentImg.offsetHeight,
          width: contentImg.offsetWidth,
        };

        this.onResize({ width: this.baseImageSize.width, height: this.baseImageSize.height });
      });
    },
  },
};
</script>

<template>
  <div class="m-auto js-design-image" :class="{ 'h-100 w-100 d-flex-center': !imageStyle }">
    <img
      ref="contentImg"
      class="mh-100"
      :src="image"
      :alt="name"
      :style="imageStyle"
      :class="{ 'img-fluid': !imageStyle }"
      @load="onImgLoad"
    />
  </div>
</template>
