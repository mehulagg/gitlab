<script>
import { mapState, mapActions, mapGetters } from 'vuex';
import tooltip from '~/vue_shared/directives/tooltip';
import CommitFilesList from './commit_sidebar/list.vue';
import EmptyState from './commit_sidebar/empty_state.vue';

export default {
  components: {
    CommitFilesList,
    EmptyState,
  },
  directives: {
    tooltip,
  },
  computed: {
    ...mapState(['changedFiles', 'lastCommitMsg']),
    ...mapState('commit', ['commitMessage', 'submitCommitLoading']),
    ...mapGetters(['lastOpenedFile', 'someUncommittedChanges', 'activeFile']),
    ...mapGetters('commit', ['discardDraftButtonDisabled']),
    showChangesArea() {
      return Boolean(this.someUncommittedChanges || this.lastCommitMsg);
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
      const file =
        this.lastOpenedFile && this.lastOpenedFile.type !== 'tree'
          ? this.lastOpenedFile
          : this.activeFile;

      if (!file) return;

      this.openPendingTab(file)
        .then(changeViewer => {
          if (changeViewer) {
            this.updateViewer('diff');
          }
        })
        .catch(e => {
          throw e;
        });
    },
  },
};
</script>

<template>
  <div class="multi-file-commit-panel-section">
    <template v-if="showChangesArea">
      <commit-files-list
        :file-list="changedFiles"
        :empty-state-text="__('There are no changes')"
        class="is-first"
        icon-name="unstaged"
      />
    </template>
    <empty-state v-else />
  </div>
</template>
