<script>
import { GlSprintf } from '@gitlab/ui';
import { __ } from '~/locale';

export default {
  components: {
    GlSprintf,
  },
  i18n: {
    commitStatSummary: __('Showing %{conflict} between %{sourceBranch} and %{targetBranch}'),
  },
};
</script>
<template>
  <div>
    <div v-if="$root.isLoading" class="loading">
      <div class="spinner spinner-md"></div>
    </div>
    <div v-if="$root.hasError" class="nothing-here-block">
      {{ $root.conflictsData.errorMessage }}
    </div>
    <div
      v-if="!$root.isLoading && !$root.hasError"
      class="content-block oneline-block files-changed"
    >
      <div v-if="$root.showDiffViewTypeSwitcher" class="inline-parallel-buttons">
        <div class="btn-group">
          <button
            :class="{ active: !$root.isParallel }"
            class="btn gl-button"
            @click="$root.handleViewTypeChange('inline')"
          >
            {{ __('Inline') }}
          </button>
          <button
            :class="{ active: $root.isParallel }"
            class="btn gl-button"
            @click="$root.handleViewTypeChange('parallel')"
          >
            {{ __('Side-by-side') }}
          </button>
        </div>
      </div>
      <div class="js-toggle-container">
        <div class="commit-stat-summary">
          <gl-sprintf :message="$options.i18n.commitStatSummary">
            <template #conflict>
              <strong class="cred">
                {{ $root.conflictsCountText }}
              </strong>
            </template>
            <template #sourceBranch>
              <strong class="ref-name">
                {{ $root.conflictsData.sourceBranch }}
              </strong>
            </template>
            <template #targetBranch>
              <strong class="ref-name">
                {{ $root.conflictsData.targetBranch }}
              </strong>
            </template>
          </gl-sprintf>
        </div>
      </div>
    </div>
  </div>
</template>
