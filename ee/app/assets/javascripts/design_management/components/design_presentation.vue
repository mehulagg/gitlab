<script>
import _ from 'underscore';
import DesignImage from './image.vue';
import DesignOverlay from './design_overlay.vue';
import { getViewportCenter } from '../utils/design_management_utils';

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
    isAnnotating: {
      type: Boolean,
      required: false,
      default: false,
    },
    scale: {
      type: Number,
      required: false,
      default: 1,
    },
  },
  data() {
    return {
      overlayDimensions: null,
      overlayPosition: null,
      currentAnnotationCoordinates: null,
      zoomFocalPoint: {
        x: 0,
        y: 0,
        width: 0,
        height: 0,
      },
      initialLoad: true,
    };
  },
  computed: {
    discussionStartingNotes() {
      return this.discussions.map(discussion => discussion.notes[0]);
    },
    currentCommentForm() {
      return (this.isAnnotating && this.currentAnnotationCoordinates) || null;
    },
  },
  beforeDestroy() {
    const { presentationViewport } = this.$refs;
    if (!presentationViewport) return;

    presentationViewport.removeEventListener('scroll', this.scrollThrottled, false);
  },
  mounted() {
    const { presentationViewport } = this.$refs;
    if (!presentationViewport) return;

    this.scrollThrottled = _.throttle(() => {
      this.shiftZoomFocalPoint();
    }, 400);

    presentationViewport.addEventListener('scroll', this.scrollThrottled, false);
  },
  methods: {
    setOverlayDimensions(overlayDimensions) {
      this.overlayDimensions = overlayDimensions;
    },
    setOverlayPosition() {
      if (!this.overlayDimensions) {
        this.overlayPosition = {};
      }

      const { presentationViewport } = this.$refs;
      if (!presentationViewport) return;

      // default to center
      this.overlayPosition = {
        left: `calc(50% - ${this.overlayDimensions.width / 2}px)`,
        top: `calc(50% - ${this.overlayDimensions.height / 2}px)`,
      };

      // if the overlay overflows, then don't center
      if (this.overlayDimensions.width > presentationViewport.offsetWidth) {
        this.overlayPosition.left = '0';
      }
      if (this.overlayDimensions.height > presentationViewport.offsetHeight) {
        this.overlayPosition.top = '0';
      }
    },
    scrollToFocalPoint() {
      const { presentationViewport } = this.$refs;
      if (!presentationViewport) return;

      const scrollX = this.zoomFocalPoint.x - presentationViewport.offsetWidth / 2;
      const scrollY = this.zoomFocalPoint.y - presentationViewport.offsetHeight / 2;

      presentationViewport.scrollTo(scrollX, scrollY);
    },
    scaleZoomFocalPoint() {
      const { x, y, width, height } = this.zoomFocalPoint;
      const widthRatio = this.overlayDimensions.width / width;
      const heightRatio = this.overlayDimensions.height / height;
      this.zoomFocalPoint = {
        x: Math.round(x * widthRatio),
        y: Math.round(y * heightRatio),
        ...this.overlayDimensions,
      };
    },
    shiftZoomFocalPoint() {
      const { presentationViewport } = this.$refs;
      if (!presentationViewport) return;

      this.zoomFocalPoint = {
        ...getViewportCenter(presentationViewport),
        ...this.overlayDimensions,
      };
    },
    onImageResize(imageDimensions) {
      this.setOverlayDimensions(imageDimensions);
      this.setOverlayPosition();

      this.$nextTick(() => {
        if (this.initialLoad) {
          // set focal point on initial load
          this.shiftZoomFocalPoint();
        } else {
          this.scaleZoomFocalPoint();
          this.scrollToFocalPoint();
        }

        if (this.overlayDimensions.width > 0) {
          this.initialLoad = false;
        }
      });
    },
    openCommentForm(position) {
      const { x, y } = position;
      const { width, height } = this.overlayDimensions;
      this.currentAnnotationCoordinates = {
        x,
        y,
        width,
        height,
      };
      this.$emit('openCommentForm', this.currentAnnotationCoordinates);
    },
  },
};
</script>

<template>
  <div ref="presentationViewport" class="h-100 w-100 p-3 overflow-auto position-relative">
    <div class="h-100 w-100 d-flex align-items-center position-relative">
      <design-image
        v-if="image"
        :image="image"
        :name="imageName"
        :scale="scale"
        @resize="onImageResize"
      />
      <design-overlay
        v-if="overlayDimensions && overlayPosition"
        :dimensions="overlayDimensions"
        :position="overlayPosition"
        :notes="discussionStartingNotes"
        :current-comment-form="currentCommentForm"
        @openCommentForm="openCommentForm"
      />
    </div>
  </div>
</template>
