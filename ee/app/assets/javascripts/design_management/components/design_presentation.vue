<script>
import _ from 'underscore';
import DesignImage from './image.vue';
import DesignOverlay from './design_overlay.vue';

const CLICK_DRAG_MOVEMENT_SPEED = 5;
const CLICK_DRAG_NATURAL_DIRECTION = true;

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
      mousedown: false,
      clickDragging: false,
      lastDragPosition: {
        x: 0,
        y: 0,
      },
    };
  },
  computed: {
    discussionStartingNotes() {
      return this.discussions.map(discussion => discussion.notes[0]);
    },
    currentCommentForm() {
      return (this.isAnnotating && this.currentAnnotationCoordinates) || null;
    },
    presentationViewportStyle() {
      if (this.clickDragging) {
        return {
          cursor: 'grabbing',
        };
      }

      return null;
    },
  },
  beforeDestroy() {
    const { presentationViewport } = this.$refs;
    if (!presentationViewport) return;

    presentationViewport.removeEventListener('scroll', this.scrollThrottled, false);
    presentationViewport.removeEventListener('mousemove', this.clickAndDrag, false);
    presentationViewport.removeEventListener('mousedown', this.mousedownHandler, false);
    document.removeEventListener('mouseup', this.mouseupHandler, false);
  },
  mounted() {
    const { presentationViewport } = this.$refs;
    if (!presentationViewport) return;

    this.scrollThrottled = _.throttle(() => {
      this.shiftZoomFocalPoint();
    }, 400);

    const getScrollDirection = (delta, natural = CLICK_DRAG_NATURAL_DIRECTION) =>
      (delta > 0 ? 1 : -1) * (natural ? 1 : -1);

    this.clickAndDrag = _.throttle(e => {
      if (!this.mousedown) return;
      this.clickDragging = true;

      const deltaX = this.lastDragPosition.x - e.clientX;
      const deltaY = this.lastDragPosition.y - e.clientY;

      if (deltaX !== 0) {
        const direction = getScrollDirection(deltaX);
        const scrollAmount = CLICK_DRAG_MOVEMENT_SPEED * direction;
        presentationViewport.scrollLeft += scrollAmount;
      }

      if (deltaY !== 0) {
        const direction = getScrollDirection(deltaY);
        const scrollAmount = CLICK_DRAG_MOVEMENT_SPEED * direction;
        presentationViewport.scrollTop += scrollAmount;
      }

      this.lastDragPosition = {
        x: e.clientX,
        y: e.clientY,
      };
    }, 1);

    this.mousedownHandler = () => {
      if (!this.isDesignOverflowing()) return;

      this.mousedown = true;
    };

    this.mouseupHandler = () => {
      this.mousedown = false;
      this.clickDragging = false;
    };

    // add various event listeners
    presentationViewport.addEventListener('scroll', this.scrollThrottled, false);
    presentationViewport.addEventListener('mousemove', this.clickAndDrag, false);
    presentationViewport.addEventListener('mousedown', this.mousedownHandler, false);
    document.addEventListener('mouseup', this.mouseupHandler, false);
  },
  methods: {
    isDesignOverflowing() {
      const { presentationContainer } = this.$refs;
      if (!presentationContainer) return false;

      return (
        presentationContainer.scrollWidth > presentationContainer.offsetWidth ||
        presentationContainer.scrollHeight > presentationContainer.offsetHeight
      );
    },
    setOverlayDimensions(overlayDimensions) {
      this.overlayDimensions = overlayDimensions;
    },
    setOverlayPosition() {
      if (!this.overlayDimensions) {
        this.overlayPosition = {};
        return;
      }

      const { presentationContainer } = this.$refs;
      if (!presentationContainer) return;

      // default to center
      this.overlayPosition = {
        left: `calc(50% - ${this.overlayDimensions.width / 2}px)`,
        top: `calc(50% - ${this.overlayDimensions.height / 2}px)`,
      };

      // if the overlay overflows, then don't center
      if (this.overlayDimensions.width > presentationContainer.offsetWidth) {
        this.overlayPosition.left = '0';
      }
      if (this.overlayDimensions.height > presentationContainer.offsetHeight) {
        this.overlayPosition.top = '0';
      }
    },
    /**
     * Return a point that represents the center of an
     * overflowing child element w.r.t it's parent
     */
    getViewportCenter() {
      const { presentationViewport } = this.$refs;
      if (!presentationViewport) return {};

      // get height of scroll bars (i.e. the max values for scrollTop, scrollLeft)
      const scrollBarWidth = presentationViewport.scrollWidth - presentationViewport.offsetWidth;
      const scrollBarHeight = presentationViewport.scrollHeight - presentationViewport.offsetHeight;

      // determine how many child pixels have been scrolled
      const xScrollRatio =
        presentationViewport.scrollLeft > 0 ? presentationViewport.scrollLeft / scrollBarWidth : 0;
      const yScrollRatio =
        presentationViewport.scrollTop > 0 ? presentationViewport.scrollTop / scrollBarHeight : 0;
      const xScrollOffset =
        (presentationViewport.scrollWidth - presentationViewport.offsetWidth - 0) * xScrollRatio;
      const yScrollOffset =
        (presentationViewport.scrollHeight - presentationViewport.offsetHeight - 0) * yScrollRatio;

      const viewportCenterX = presentationViewport.offsetWidth / 2;
      const viewportCenterY = presentationViewport.offsetHeight / 2;
      const focalPointX = viewportCenterX + xScrollOffset;
      const focalPointY = viewportCenterY + yScrollOffset;

      return {
        x: focalPointX,
        y: focalPointY,
      };
    },
    /**
     * Scroll the viewport such that the focal point is positioned centrally
     */
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
        x: Math.round(x * widthRatio * 100) / 100,
        y: Math.round(y * heightRatio * 100) / 100,
        ...this.overlayDimensions,
      };
    },
    shiftZoomFocalPoint() {
      this.zoomFocalPoint = {
        ...this.getViewportCenter(),
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
          this.initialLoad = false;
        } else {
          this.scaleZoomFocalPoint();
          this.scrollToFocalPoint();
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
  <div
    ref="presentationViewport"
    class="h-100 w-100 p-3 overflow-auto position-relative"
    :style="presentationViewportStyle"
  >
    <div
      ref="presentationContainer"
      class="h-100 w-100 d-flex align-items-center position-relative"
    >
      <design-image
        v-if="image"
        :image="image"
        :name="imageName"
        :scale="scale"
        @resize="onImageResize"
      />
      <design-overlay
        v-if="overlayDimensions && overlayPosition"
        :disable-commenting="clickDragging"
        :dimensions="overlayDimensions"
        :position="overlayPosition"
        :notes="discussionStartingNotes"
        :current-comment-form="currentCommentForm"
        @openCommentForm="openCommentForm"
      />
    </div>
  </div>
</template>
