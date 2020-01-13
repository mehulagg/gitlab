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
    isAnnotating: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  data() {
    return {
      overlayDimensions: null,
      overlayPosition: null,
      currentAnnotationCoordinates: null,
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
    onImageResize(imageDimensions) {
      this.setOverlayDimensions(imageDimensions);
      this.setOverlayPosition();
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
      <design-image v-if="image" :image="image" :name="imageName" @resize="onImageResize" />
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
