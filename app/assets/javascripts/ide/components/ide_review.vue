<script>
import { mapGetters, mapState, mapActions } from 'vuex';
import { viewerTypes } from '../constants';
import EditorModeDropdown from './editor_mode_dropdown.vue';
import IdeTreeList from './ide_tree_list.vue';

export default {
  components: {
    IdeTreeList,
    EditorModeDropdown,
  },
  computed: {
    ...mapGetters(['currentMergeRequest', 'activeFile', 'getUrlForPath']),
    ...mapState(['viewer', 'currentMergeRequestId']),
    showLatestChangesText() {
      return !this.currentMergeRequestId || this.viewer === viewerTypes.diff;
    },
    showMergeRequestText() {
      return this.currentMergeRequestId && this.viewer === viewerTypes.mr;
    },
    mergeRequestId() {
      return `!${this.currentMergeRequest.iid}`;
    },
  },
  mounted() {
    this.initialize();
  },
  activated() {
    this.initialize();
  },
  methods: {
    ...mapActions(['updateViewer', 'updateRouteWithActiveFile']),
    initialize() {
      this.$nextTick(() => {
        this.updateViewer(this.currentMergeRequestId ? viewerTypes.mr : viewerTypes.diff);
      });

      this.updateRouteWithActiveFile();
    },
  },
};
</script>

<template>
  <ide-tree-list header-class="ide-review-header">
    <template #header>
      <div class="ide-review-button-holder">
        {{ __('Review') }}
        <editor-mode-dropdown
          v-if="currentMergeRequest"
          :viewer="viewer"
          :merge-request-id="currentMergeRequest.iid"
          @click="updateViewer"
        />
      </div>
      <div class="gl-mt-2 ide-review-sub-header">
        <template v-if="showLatestChangesText">
          {{ __('Latest changes') }}
        </template>
        <template v-else-if="showMergeRequestText">
          {{ __('Merge request') }} (<a
            v-if="currentMergeRequest"
            :href="currentMergeRequest.web_url"
            v-text="mergeRequestId"
          ></a
          >)
        </template>
      </div>
    </template>
  </ide-tree-list>
</template>
