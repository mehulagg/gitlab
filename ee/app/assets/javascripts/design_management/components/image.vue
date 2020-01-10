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
      baseImageSize: {},
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
      this.$emit('resize', val);
    }, 400);

    window.addEventListener('resize', this.resizeThrottled, false);
  },
  methods: {
    onImgLoad() {
      requestIdleCallback(this.resetImageSize, { timeout: 1000 });
    },
    setImageSize({ width, height }) {
      // unset max-width so we have full control over dimensions
      this.imageStyle = {
        maxWidth: 'unset',
        width: `${width}px`,
        height: `${height}px`,
      };
      this.$emit('resize', { width, height });
    },
    zoom(amount) {
      const width = this.baseImageSize.width * amount;
      const height = this.baseImageSize.height * amount;
      this.setImageSize({ width, height });
    },
    resetImageSize() {
      const { contentImg } = this.$refs;
      if (!contentImg) return;

      // wipe image style so max-width can be 100%
      this.imageStyle = {};
      this.$nextTick(() => {
        this.baseImageSize = {
          height: contentImg.offsetHeight,
          width: contentImg.offsetWidth,
        };

        this.$emit('resize', this.baseImageSize);
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
