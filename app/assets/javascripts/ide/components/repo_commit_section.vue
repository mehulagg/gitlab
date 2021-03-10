<script>
import { mapState, mapActions, mapGetters } from 'vuex';
import { stageKeys, viewerTypes } from '../constants';
import EmptyState from './commit_sidebar/empty_state.vue';
import CommitFilesList from './commit_sidebar/list.vue';

export default {
  components: {
    CommitFilesList,
    EmptyState,
  },
  computed: {
    ...mapState(['changedFiles', 'stagedFiles', 'lastCommitMsg', 'activeCommitFile']),
    ...mapState('commit', ['commitMessage', 'submitCommitLoading']),
    ...mapGetters(['lastOpenedFile', 'someUncommittedChanges', 'activeFile']),
    ...mapGetters('commit', ['discardDraftButtonDisabled']),
    showStageUnstageArea() {
      return Boolean(this.someUncommittedChanges || this.lastCommitMsg);
    },
    activeFileKey() {
      return this.activeFile ? this.activeFile.key : null;
    },
  },
  mounted() {
    this.initialize();
  },
  activated() {
    this.initialize();
  },
  methods: {
    ...mapActions(['openPendingTab', 'updateViewer', 'updateActivityBarView']),
    initialize() {
      this.$nextTick(() => {
        this.updateViewer(viewerTypes.diff);
      });

      this.openPendingTab(this.getInitializationPath());
    },
    // We do not want caching, so we use a method instead of a computed here.
    getInitializationPath() {
      const file =
        this.lastOpenedFile && this.lastOpenedFile.type !== 'tree'
          ? this.lastOpenedFile
          : this.activeFile;

      return file?.path || this.activeCommitFile || Object.values(this.stagedFiles)[0];
    },
  },
  stageKeys,
};
</script>

<template>
  <div class="multi-file-commit-panel-section">
    <template v-if="showStageUnstageArea">
      <commit-files-list
        :key-prefix="$options.stageKeys.staged"
        :file-list="stagedFiles"
        :active-file-key="activeFileKey"
        :empty-state-text="__('There are no changes')"
        class="is-first"
      />
    </template>
    <empty-state v-else />
  </div>
</template>
