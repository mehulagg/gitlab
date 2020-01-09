<script>
import DesignImage from './image.vue';
import DesignOverlay from './design_overlay.vue';

export default {
  components: {
    DesignImage,
    DesignOverlay,
  },
  props: {
    image: {
      type: String,
      required: false,
      default: '',
    },
    imageName: {
      type: String,
      required: false,
      default: '',
    },
    discussions: {
      type: Array,
      required: true,
    },
    scale: {
      type: Number,
      required: false,
      default: 1,
    },
    annotationCoordinates: {
      type: Object,
      required: false,
      default: null,
    },
  },
  data() {
    return {
      overlayDimensions: {
        width: 0,
        height: 0,
      },
      overlayPosition: {
        top: '0',
        left: '0',
      },
      zoomFocalPoint: {
        xRatio: 0.5,
        yRatio: 0.5,
      },
      userScrolling: false,
      initialLoad: true,
    };
  },
  computed: {
    discussionStartingNotes() {
      return this.discussions.map(discussion => discussion.notes[0]);
    },
  },
  mounted() {
    const { presentationViewport } = this.$refs;
    if (!presentationViewport) return;

    // TODO: throttle
    // presentationViewport.addEventListener('scroll', () => {
    //   if (!this.userScrolling) {
    //     return;
    //   }
    //   console.log('user scrolling...');

    //   this.setZoomFocalPoint();
    // });
  },
  methods: {
    scrollToFocalPoint() {
      const { presentationViewport } = this.$refs;
      if (!presentationViewport) return;

      this.$nextTick(() => {
        const scrollBarWidth = presentationViewport.scrollWidth - presentationViewport.offsetWidth;
        const scrollBarHeight =
          presentationViewport.scrollHeight - presentationViewport.offsetHeight;

        const x = scrollBarWidth * this.zoomFocalPoint.xRatio;
        const y = scrollBarHeight * this.zoomFocalPoint.yRatio;

        this.userScrolling = false;
        presentationViewport.scrollTo(x, y);
        // this.userScrolling = true;
      });
    },
    setInitialZoomFocalPoint() {
      const { presentationViewport } = this.$refs;
      if (!presentationViewport) return;

      const xRatio = 0.5;
      const yRatio =
        presentationViewport.scrollHeight > 0
          ? presentationViewport.offsetHeight / 2 / presentationViewport.scrollHeight
          : 0.5;

      this.zoomFocalPoint = {
        xRatio,
        yRatio,
      };
    },
    // setZoomFocalPoint() {
    //   if (!this.userScrolling) return;

    //   const { presentationViewport } = this.$refs;
    //   if (!presentationViewport) return;

    //   const scrollBarWidth = presentationViewport.scrollWidth - presentationViewport.offsetWidth;
    //   const scrollBarHeight = presentationViewport.scrollHeight - presentationViewport.offsetHeight;

    //   const xRatio =
    //     presentationViewport.scrollLeft > 0 ? presentationViewport.scrollLeft / scrollBarWidth : 0;
    //   const yRatio =
    //     presentationViewport.scrollTop > 0 ? presentationViewport.scrollTop / scrollBarHeight : 0;

    //   this.zoomFocalPoint = {
    //     xRatio,
    //     yRatio,
    //   };

    //   console.log('New focal point:', {
    //     xRatio,
    //     yRatio,
    //   });
    // },
    setOverlayPosition() {
      const { presentationViewport } = this.$refs;
      if (!presentationViewport) return;

      this.overlayPosition = {
        left: `calc(50% - ${this.overlayDimensions.width / 2}px)`,
        top: `calc(50% - ${this.overlayDimensions.height / 2}px)`,
      };

      if (this.overlayDimensions.width > presentationViewport.offsetWidth) {
        this.overlayPosition.left = '0';
      }

      if (this.overlayDimensions.height > presentationViewport.offsetHeight) {
        this.overlayPosition.top = '0';
      }
    },
    setOverlayDimensions({ width, height }) {
      this.overlayDimensions.width = width;
      this.overlayDimensions.height = height;

      this.setOverlayPosition();
      if (!this.initialLoad) {
        this.scrollToFocalPoint();
      } else {
        this.setInitialZoomFocalPoint();
      }

      if (this.overlayDimensions.width > 0) {
        this.initialLoad = false;
      }
    },
    openCommentForm(position) {
      const { x, y } = position;
      const { width, height } = this.overlayDimensions;
      const annotationCoordinates = {
        ...this.annotationCoordinates,
        x,
        y,
        width,
        height,
      };
      this.$emit('openCommentForm', annotationCoordinates);
    },
  },
};
</script>

<template>
  <div ref="presentationViewport" class="h-100 w-100 p-3 overflow-auto">
    <div class="h-100 w-100 d-flex align-items-center position-relative">
      <design-image
        :image="image"
        :name="imageName"
        :scale="scale"
        @resized="setOverlayDimensions"
      />
      <design-overlay
        v-if="overlayDimensions && overlayPosition"
        :dimensions="overlayDimensions"
        :position="overlayPosition"
        :notes="discussionStartingNotes"
        :current-comment-form="annotationCoordinates"
        @openCommentForm="openCommentForm"
      />
    </div>
  </div>
</template>
