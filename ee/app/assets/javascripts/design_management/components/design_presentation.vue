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
      type: Object,
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
    };
  },
  computed: {
    discussionStartingNotes() {
      return this.discussions.map(discussion => discussion.notes[0]);
    },
  },
  methods: {
    setOverlayDimensions(position) {
      this.overlayDimensions.width = position.width;
      this.overlayDimensions.height = position.height;

      const { imgWrapper } = this.$refs;
      if (!imgWrapper) return;

      const scrollWidth = imgWrapper.scrollWidth - imgWrapper.offsetWidth;
      const scrollHeight = imgWrapper.scrollHeight - imgWrapper.offsetHeight;
      imgWrapper.scrollTo(scrollWidth / 2, scrollHeight / 2);
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
  <div class="position-relative" style="margin:auto;">
    <design-image
      :image="image"
      :name="imageName"
      :scale="scale"
      @setOverlayDimensions="setOverlayDimensions"
    />
    <design-overlay
      :position="overlayDimensions"
      :notes="discussionStartingNotes"
      :current-comment-form="annotationCoordinates"
      @openCommentForm="openCommentForm"
    />
  </div>
</template>
