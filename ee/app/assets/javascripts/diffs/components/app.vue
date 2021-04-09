<script>
import { mapState, mapActions } from 'vuex';
import CEDiffsApp from '~/diffs/components/app.vue';

export default {
  extends: CEDiffsApp,
  props: {
    endpointCodequality: {
      type: String,
      required: false,
      default: '',
    },
  },
  computed: {
    ...mapState({
      codequalityDiff: (state) => state.diffs.codequalityDiff,
    }),
  },
  watch: {
    shouldShow() {
      if (this.isLoading) {
        this.fetchCodequality();
      }
    },
  },
  mounted() {
    this.setCodequalityEndpoint(this.endpointCodequality);

    if (this.shouldShow) {
      this.fetchCodequality();
    }
  },
  methods: {
    ...mapActions('diffs', ['setCodequalityEndpoint', 'fetchCodequality']),
  },
};
</script>

<template>
  <div v-show="shouldShow">
    <div v-if="isLoading || !isTreeLoaded" class="loading"><gl-loading-icon size="lg" /></div>
    <div v-else id="diffs" :class="{ active: shouldShow }" class="diffs tab-pane">
      <compare-versions
        :is-limited-container="isLimitedContainer"
        :diff-files-count-text="numTotalFiles"
      />

      <hidden-files-warning
        v-if="visibleWarning == $options.alerts.ALERT_OVERFLOW_HIDDEN"
        :visible="numVisibleFiles"
        :total="numTotalFiles"
        :plain-diff-path="plainDiffPath"
        :email-patch-path="emailPatchPath"
      />
      <merge-conflict-warning
        v-if="visibleWarning == $options.alerts.ALERT_MERGE_CONFLICT"
        :limited="isLimitedContainer"
        :resolution-path="conflictResolutionPath"
        :mergeable="canMerge"
      />
      <collapsed-files-warning
        v-if="visibleWarning == $options.alerts.ALERT_COLLAPSED_FILES"
        :limited="isLimitedContainer"
      />

      <div
        :data-can-create-note="getNoteableData.current_user.can_create_note"
        class="files d-flex gl-mt-2"
      >
        <div
          v-if="renderFileTree"
          :style="{ width: `${treeWidth}px` }"
          class="diff-tree-list js-diff-tree-list px-3 pr-md-0"
        >
          <panel-resizer
            :size.sync="treeWidth"
            :start-size="treeWidth"
            :min-size="$options.minTreeWidth"
            :max-size="$options.maxTreeWidth"
            side="right"
            @resize-end="cacheTreeListWidth"
          />
          <tree-list :hide-file-stats="hideFileStats" />
        </div>
        <div
          class="col-12 col-md-auto diff-files-holder"
          :class="{
            [CENTERED_LIMITED_CONTAINER_CLASSES]: isLimitedContainer,
          }"
        >
          <commit-widget v-if="commit" :commit="commit" :collapsible="false" />
          <div v-if="isBatchLoading" class="loading"><gl-loading-icon size="lg" /></div>
          <template v-else-if="renderDiffFiles">
            <diff-file
              v-for="(file, index) in diffs"
              :key="file.newPath"
              :file="file"
              :reviewed="fileReviews[file.id]"
              :is-first-file="index === 0"
              :is-last-file="index === diffFilesLength - 1"
              :help-page-path="helpPagePath"
              :can-current-user-fork="canCurrentUserFork"
              :view-diffs-file-by-file="viewDiffsFileByFile"
            />
            <div
              v-if="showFileByFileNavigation"
              data-testid="file-by-file-navigation"
              class="gl-display-grid gl-text-center"
            >
              <gl-pagination
                class="gl-mx-auto"
                :value="currentFileNumber"
                :prev-page="previousFileNumber"
                :next-page="nextFileNumber"
                @input="navigateToDiffFileNumber"
              />
              <gl-sprintf :message="__('File %{current} of %{total}')">
                <template #current>{{ currentFileNumber }}</template>
                <template #total>{{ diffFiles.length }}</template>
              </gl-sprintf>
            </div>
            <gl-loading-icon v-else-if="retrievingBatches" size="lg" />
          </template>
          <no-changes v-else :changes-empty-state-illustration="changesEmptyStateIllustration" />
        </div>
      </div>
    </div>
  </div>
</template>
