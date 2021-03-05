<script>
import { sprintf, __ } from '~/locale';
import TreeContent from '../components/tree_content.vue';
import preloadMixin from '../mixins/preload';
import { updateElementsVisibility } from '../utils/dom';

export default {
  directoryLockButton: null,
  components: {
    TreeContent,
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
    '$route.params.path': function (path) {
      if (!path) return;

      this.updateDirectoryLockButton(path.replace(/^\//, ''));
    },
  },
  mounted() {
    this.$options.directoryLockButton = document.querySelector('.js-path-lock');
  },
  methods: {
    updateElements(isRoot) {
      updateElementsVisibility('.js-show-on-root', isRoot);
      updateElementsVisibility('.js-hide-on-root', !isRoot);
    },
    updateDirectoryLockButton(path) {
      const { directoryLockButton } = this.$options;
      if (!directoryLockButton) return;

      const {
        dataset: { state, modalAttributes },
      } = directoryLockButton;

      if (!modalAttributes || !state) return;

      const message =
        state === 'lock'
          ? __('Are you sure you want to lock the %{codeOpen}%{path}%{codeClose} directory?')
          : __('Are you sure you want to unlock the %{codeOpen}%{path}%{codeClose} directory?');

      const newModalAttributes = {
        ...JSON.parse(modalAttributes),
        messageHtml: sprintf(message, { codeOpen: '<code>', path, codeClose: '</code>' }, false),
      };

      directoryLockButton.setAttribute('data-form-data', JSON.stringify({ path }));
      directoryLockButton.setAttribute('data-modal-attributes', JSON.stringify(newModalAttributes));
    },
  },
};
</script>

<template>
  <tree-content :path="path" :loading-path="loadingPath" />
</template>
