<script>
import { GlTooltipDirective, GlIcon, GlLink, GlButtonGroup, GlButton, GlSprintf } from '@gitlab/ui';
import { mapActions, mapGetters, mapState } from 'vuex';
import { __ } from '~/locale';
import { setUrlParams } from '../../lib/utils/url_utility';
import { CENTERED_LIMITED_CONTAINER_CLASSES, EVT_EXPAND_ALL_FILES } from '../constants';
import eventHub from '../event_hub';
import CompareDropdownLayout from './compare_dropdown_layout.vue';
import DiffStats from './diff_stats.vue';
import SettingsDropdown from './settings_dropdown.vue';

export default {
  components: {
    CompareDropdownLayout,
    GlIcon,
    GlLink,
    GlButtonGroup,
    GlButton,
    GlSprintf,
    SettingsDropdown,
    DiffStats,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    isLimitedContainer: {
      type: Boolean,
      required: false,
      default: false,
    },
    diffFilesCountText: {
      type: String,
      required: false,
      default: null,
    },
  },
  computed: {
    ...mapGetters('diffs', [
      'whichCollapsedTypes',
      'diffCompareDropdownTargetVersions',
      'diffCompareDropdownSourceVersions',
    ]),
    ...mapState('diffs', [
      'diffFiles',
      'commit',
      'showTreeList',
      'startVersion',
      'latestVersionPath',
      'addedLines',
      'removedLines',
    ]),
    toggleFileBrowserTitle() {
      return this.showTreeList ? __('Hide file browser') : __('Show file browser');
    },
    hasChanges() {
      return this.diffFiles.length > 0;
    },
    hasSourceVersions() {
      return this.diffCompareDropdownSourceVersions.length > 0;
    },
    nextCommitUrl() {
      return this.commit.next_commit_id
        ? setUrlParams({ commit_id: this.commit.next_commit_id })
        : '';
    },
    previousCommitUrl() {
      return this.commit.prev_commit_id
        ? setUrlParams({ commit_id: this.commit.prev_commit_id })
        : '';
    },
    hasNeighborCommits() {
      return this.commit && (this.commit.next_commit_id || this.commit.prev_commit_id);
    },
  },
  created() {
    this.CENTERED_LIMITED_CONTAINER_CLASSES = CENTERED_LIMITED_CONTAINER_CLASSES;
  },
  methods: {
    ...mapActions('diffs', ['setInlineDiffViewType', 'setParallelDiffViewType', 'setShowTreeList']),
    expandAllFiles() {
      eventHub.$emit(EVT_EXPAND_ALL_FILES);
    },
    ...mapActions('diffs', ['moveToNeighboringCommit']),
  },
};
</script>

<template>
  <div class="mr-version-controls border-top">
    <div
      class="mr-version-menus-container content-block"
      :class="{
        [CENTERED_LIMITED_CONTAINER_CLASSES]: isLimitedContainer,
      }"
    >
      <gl-button
        v-if="hasChanges"
        v-gl-tooltip.hover
        variant="default"
        icon="file-tree"
        class="gl-mr-3 js-toggle-tree-list"
        :title="toggleFileBrowserTitle"
        :aria-label="toggleFileBrowserTitle"
        :selected="showTreeList"
        @click="setShowTreeList({ showTreeList: !showTreeList })"
      />
      <div v-if="commit" class="commit-nav-buttons">
        <gl-button-group>
          <gl-button
            :href="previousCommitUrl"
            :disabled="!commit.prev_commit_id"
            @click.prevent="moveToNeighboringCommit({ direction: 'previous' })"
          >
            <span
              v-if="!commit.prev_commit_id"
              v-gl-tooltip
              class="h-100 w-100 position-absolute position-top-0 position-left-0"
              :title="__('You\'re at the first commit')"
            ></span>
            <gl-icon name="chevron-left" />
            {{ __('Prev') }}
          </gl-button>
          <gl-button
            :href="commit.commit_url"
            class="monospace"
          >
            {{ commit.short_id }}
          </gl-button>
          <gl-button
            :href="nextCommitUrl"
            :disabled="!commit.next_commit_id"
            @click.prevent="moveToNeighboringCommit({ direction: 'next' })"
          >
            <span
              v-if="!commit.next_commit_id"
              v-gl-tooltip
              class="h-100 w-100 position-absolute position-top-0 position-left-0"
              :title="__('You\'re at the last commit')"
            ></span>
            {{ __('Next') }}
            <gl-icon name="chevron-right" />
          </gl-button>
        </gl-button-group>
      </div>
      <div
        v-else-if="!commit && hasSourceVersions"
        class="d-flex align-items-center compare-versions-container"
      >
        <compare-dropdown-layout
          :versions="diffCompareDropdownTargetVersions"
          data-qa-selector="target_version_dropdown"
          />
        <gl-icon
          name="comparison"
          class="text-secondary gl-ml-3 gl-mr-3" />
        <compare-dropdown-layout
          :versions="diffCompareDropdownSourceVersions"
        />
      </div>
      <gl-button
        v-if="commit || startVersion"
        :href="latestVersionPath"
        variant="default"
        class="gl-ml-3 js-latest-version"
        >
        {{ __('Show latest version') }}
      </gl-button>
      <div v-if="hasChanges" class="inline-parallel-buttons d-none d-md-flex ml-auto">
        <diff-stats
          :diff-files-count-text="diffFilesCountText"
          :added-lines="addedLines"
          :removed-lines="removedLines"
        />
        <gl-button
          v-show="whichCollapsedTypes.any"
          variant="default"
          class="gl-mr-3"
          @click="expandAllFiles"
        >
          {{ __('Expand all') }}
        </gl-button>
        <settings-dropdown />
      </div>
    </div>
  </div>
</template>
