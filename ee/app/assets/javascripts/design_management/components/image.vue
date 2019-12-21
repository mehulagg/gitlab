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
      imgDimensions: {
        height: 0,
        width: 0,
      },
    };
  },
  computed: {
    // containerDimensions() {
    //   const { imgContainer } = this.$refs;
    //   if (!imgContainer)
    //     return {
    //       height: 0,
    //       width: 0,
    //     };

    //   return {
    //     height: imgContainer.height,
    //     width: imgContainer.width,
    //   };
    // },
    imgStyle() {
      if (this.imgDimensions.width === 0) return {};
      return {
        width: `${this.imgDimensions.width}px`,
        height: `${this.imgDimensions.height}px`,
      };
    },
  },
  watch: {
    scale() {
      return this.calculateImgSize();
    },
    // containerDimensions(val) {
    //   const { contentImg } = this.$refs;
    //   this.imgDimensions = {
    //     width: contentImg.naturalWidth * this.scale,
    //     height: contentImg.naturalHeight * this.scale,
    //   };
    // },
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

      this.imgDimensions = {
        width: contentImg.naturalWidth * this.scale,
        height: contentImg.naturalHeight * this.scale,
      };
      this.$nextTick(() => {
        const naturalRatio = contentImg.naturalWidth / contentImg.naturalHeight;
        const visibleRatio = contentImg.width / contentImg.height;

        const height = contentImg.clientHeight;
        // Handling the case where img element takes more width than visible image thanks to object-fit: contain
        const width =
          naturalRatio < visibleRatio
            ? contentImg.clientHeight * naturalRatio
            : contentImg.clientWidth;
        const position = {
          height,
          width,
        };

        this.$emit('setOverlayDimensions', position);
      });
    },
  },
};
</script>

<template>
  <div ref="imgContainer" class="p-3 js-design-image">
    <img
      ref="contentImg"
      :src="image"
      :alt="name"
      :style="imgStyle"
      class="d-block ml-auto mr-auto design-image"
      @load="onImgLoad"
    />
  </div>
</template>
