<script>
import BlobContent from '../components/blob_content_viewer.vue';
import { updateElementsVisibility } from '../utils/dom';
import preloadMixin from '../mixins/preload';

export default {
  components: {
    BlobContent,
  },
  mixins: [preloadMixin],
  props: {
    path: {
      type: String,
      required: false,
      default: '/',
    },
  },
  computed: {
    isRoot() {
      return this.path === '/';
    },
  },
  watch: {
    isRoot: {
      immediate: true,
      handler: 'updateElements',
    },
  },
  methods: {
    updateElements(isRoot) {
      updateElementsVisibility('.js-show-on-root', isRoot);
      updateElementsVisibility('.js-hide-on-root', !isRoot);
    },
  },
};
</script>

<template>
  <div>
    <blob-content :path="path" :loading-path="loadingPath" />
  </div>
</template>
