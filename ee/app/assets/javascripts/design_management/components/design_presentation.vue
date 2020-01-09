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
      initialLoad: true,
    };
  },
  computed: {
    discussionStartingNotes() {
      return this.discussions.map(discussion => discussion.notes[0]);
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
      this.setZoomFocalPoint();
    }, 400);

    presentationViewport.addEventListener('scroll', this.scrollThrottled, false);
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

        presentationViewport.scrollTo(x, y);
      });
    },
    setZoomFocalPoint() {
      const { presentationViewport } = this.$refs;
      if (!presentationViewport) return;

      this.zoomFocalPoint = getViewportCenter(presentationViewport);
    },
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

      if (this.initialLoad) {
        this.setZoomFocalPoint();
      } else {
        this.scrollToFocalPoint();
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
