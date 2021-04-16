<script>
/* eslint-disable vue/no-v-html */
import { mapState, mapActions } from 'vuex';
import DiffFileHeader from '~/diffs/components/diff_file_header.vue';
import ImageDiffOverlay from '~/diffs/components/image_diff_overlay.vue';
import { getDiffMode } from '~/diffs/store/utils';
import { diffViewerModes } from '~/ide/constants';
import DiffViewer from '~/vue_shared/components/diff_viewer/diff_viewer.vue';
import { isCollapsed } from '../../diffs/utils/diff_file';
import NoteDiffLines from './note_diff_lines.vue';

export default {
  components: {
    DiffFileHeader,
    DiffViewer,
    ImageDiffOverlay,
    NoteDiffLines,
  },
  props: {
    discussion: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      error: false,
    };
  },
  computed: {
    ...mapState({
      projectPath: (state) => state.diffs.projectPath,
    }),
    diffMode() {
      return getDiffMode(this.discussion.diff_file);
    },
    diffViewerMode() {
      return this.discussion.diff_file.viewer.name;
    },
    isTextFile() {
      return this.diffViewerMode === diffViewerModes.text;
    },
    hasTruncatedDiffLines() {
      return (
        this.discussion.truncated_diff_lines && this.discussion.truncated_diff_lines.length !== 0
      );
    },
    isCollapsed() {
      return isCollapsed(this.discussion.diff_file);
    },
  },
  mounted() {
    if (this.isTextFile && !this.hasTruncatedDiffLines) {
      this.fetchDiff();
    }
  },
  methods: {
    ...mapActions(['fetchDiscussionDiffLines']),
    fetchDiff() {
      this.error = false;
      this.fetchDiscussionDiffLines(this.discussion)
        .then(this.highlight)
        .catch(() => {
          this.error = true;
        });
    },
  },
};
</script>

<template>
  <div :class="{ 'text-file': isTextFile }" class="diff-file file-holder">
    <diff-file-header
      :discussion-path="discussion.discussion_path"
      :diff-file="discussion.diff_file"
      :can-current-user-fork="false"
      :expanded="!isCollapsed"
    />
    <div v-if="isTextFile" class="diff-content">
      <note-diff-lines
        :error="error"
        :has-truncated-diff-lines="hasTruncatedDiffLines"
        :lines="discussion.truncated_diff_lines"
        :reload-diff-fn="fetchDiff"
      >
        <slot></slot>
      </note-diff-lines>
    </div>
    <div v-else>
      <diff-viewer
        :diff-file="discussion.diff_file"
        :diff-mode="diffMode"
        :diff-viewer-mode="diffViewerMode"
        :new-path="discussion.diff_file.new_path"
        :new-sha="discussion.diff_file.diff_refs.head_sha"
        :old-path="discussion.diff_file.old_path"
        :old-sha="discussion.diff_file.diff_refs.base_sha"
        :file-hash="discussion.diff_file.file_hash"
        :project-path="projectPath"
      >
        <template #image-overlay="{ renderedWidth, renderedHeight }">
          <image-diff-overlay
            v-if="renderedWidth"
            :rendered-width="renderedWidth"
            :rendered-height="renderedHeight"
            :discussions="discussion"
            :file-hash="discussion.diff_file.file_hash"
            :show-comment-icon="true"
            :should-toggle-discussion="false"
            badge-class="image-comment-badge gl-text-gray-500"
          />
        </template>
      </diff-viewer>
      <slot></slot>
    </div>
  </div>
</template>
