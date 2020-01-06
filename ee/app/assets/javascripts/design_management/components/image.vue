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
      imageSize: null,
    };
  },
  computed: {
    imgStyle() {
      return {
        transform: `scale(${this.scale})`,
        // transformOrigin: `50% 50%`,
      };
    },
    containerStyle() {
      return {
        width: `${this.imageSize.width}px`,
        height: `${this.imageSize.height}px`,
        left: `calc(50% - ${this.imageSize.width / 2}px)`,
        top: `calc(50% - ${this.imageSize.height / 2}px)`,
      };
    },
  },
  watch: {
    scale() {
      return this.calculateImgSize();
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

        const height = contentImg.clientHeight;
        // Handling the case where img element takes more width than visible image thanks to object-fit: contain
        const width =
          naturalRatio < visibleRatio
            ? contentImg.clientHeight * naturalRatio
            : contentImg.clientWidth;
        const imageSize = {
          height: height * this.scale,
          width: width * this.scale,
        };

        this.imageSize = imageSize;
        this.$emit('setOverlayDimensions', imageSize);
      });
    },
  },
};
</script>

<template>
  <div class="js-design-image">
    <img
      ref="contentImg"
      :src="image"
      :alt="name"
      :style="imgStyle"
      class="img-fluid design-image js-design-image"
      @load="onImgLoad"
    />
  </div>
</template>
