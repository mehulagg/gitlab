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
    };
  },
  computed: {
    discussionStartingNotes() {
      return this.discussions.map(discussion => discussion.notes[0]);
    },
  },
  watch: {
    scale() {
      this.centerViewportScroll();
    },
  },
  methods: {
    centerViewportScroll() {
      const { presentationViewport } = this.$refs;
      if (!presentationViewport) return;

      const scrollWidth = presentationViewport.scrollWidth - presentationViewport.offsetWidth;
      const scrollHeight = presentationViewport.scrollHeight - presentationViewport.offsetHeight;
      presentationViewport.scrollTo(scrollWidth / 2, scrollHeight / 2);
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
        :dimensions="overlayDimensions"
        :position="overlayPosition"
        :notes="discussionStartingNotes"
        :current-comment-form="annotationCoordinates"
        @openCommentForm="openCommentForm"
      />
    </div>
  </div>
</template>
