<script>
import { mapActions, mapGetters } from 'vuex';
import { GlIcon } from '@gitlab/ui';
import tooltip from '~/vue_shared/directives/tooltip';
import FileIcon from '~/vue_shared/components/file_icon.vue';
import { viewerTypes } from '../../constants';
import getCommitIconMap from '../../commit_icon';

export default {
  components: {
    GlIcon,
    FileIcon,
  },
  directives: {
    tooltip,
  },
  props: {
    file: {
      type: Object,
      required: true,
    },
  },
  computed: {
    ...mapGetters(['activeFile']),
    iconName() {
      return `${getCommitIconMap(this.file).icon}`;
    },
    iconClass() {
      return `${getCommitIconMap(this.file).class} ml-auto mr-auto`;
    },
    isActive() {
      return this.activeFile.key === this.file.key;
    },
    tooltipTitle() {
      return this.file.path === this.file.name ? '' : this.file.path;
    },
  },
  methods: {
    ...mapActions(['discardFileChanges', 'updateViewer', 'openPendingTab']),
    openFileInEditor() {
      if (this.file.type === 'tree') return null;

      return this.openPendingTab(this.file).then(changeViewer => {
        if (changeViewer) {
          this.updateViewer(viewerTypes.diff);
        }
      });
    },
  },
};
</script>

<template>
  <div class="multi-file-commit-list-item position-relative">
    <div
      v-tooltip
      :title="tooltipTitle"
      :class="{
        'is-active': isActive,
      }"
      class="multi-file-commit-list-path w-100 border-0 ml-0 mr-0"
      role="button"
      @click="openFileInEditor"
    >
      <span class="multi-file-commit-list-file-path d-flex align-items-center">
        <file-icon :file-name="file.name" class="gl-mr-3" />
        <template v-if="file.prevName && file.prevName !== file.name">
          {{ file.prevName }} &#x2192;
        </template>
        {{ file.name }}
      </span>
      <div class="ml-auto d-flex align-items-center">
        <div class="d-flex align-items-center ide-commit-list-changed-icon">
          <gl-icon :name="iconName" :size="16" :class="iconClass" />
        </div>
      </div>
    </div>
  </div>
</template>
