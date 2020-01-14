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
      this.zoom(val);
    },
  },
  beforeDestroy() {
    window.removeEventListener('resize', this.resizeThrottled, false);
  },
  mounted() {
    this.onImgLoad();

    this.resizeThrottled = _.throttle(() => {
      this.onWindowResize();
    }, 400);
    window.addEventListener('resize', this.resizeThrottled, false);
  },
  methods: {
    onImgLoad() {
      requestIdleCallback(this.setBaseImageSize, { timeout: 1000 });
    },
    onWindowResize() {
      const { contentImg } = this.$refs;
      if (!contentImg) return;

      this.onResize({
        width: contentImg.offsetWidth,
        height: contentImg.offsetHeight,
      });
    },
    setBaseImageSize() {
      const { contentImg } = this.$refs;
      if (!contentImg || contentImg.offsetHeight === 0 || contentImg.offsetWidth === 0) return;

      this.baseImageSize = {
        height: contentImg.offsetHeight,
        width: contentImg.offsetWidth,
      };
      this.onResize({ width: this.baseImageSize.width, height: this.baseImageSize.height });
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
