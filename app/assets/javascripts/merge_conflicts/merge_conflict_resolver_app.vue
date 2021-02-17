<script>
import { GlSprintf } from '@gitlab/ui';
import { __ } from '~/locale';
import FileIcon from '~/vue_shared/components/file_icon.vue';
import DiffFileEditor from './components/diff_file_editor.vue';
import InlineConflictLines from './components/inline_conflict_lines.vue';
import ParallelConflictLines from './components/parallel_conflict_lines.vue';

export default {
  components: {
    GlSprintf,
    FileIcon,
    DiffFileEditor,
    InlineConflictLines,
    ParallelConflictLines,
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
    <template v-if="!$root.isLoading && !$root.hasError">
      <div class="content-block oneline-block files-changed">
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
      <div class="files-wrapper">
        <div class="files">
          <div
            v-for="file in $root.conflictsData.files"
            :key="file.blobPath"
            class="diff-file file-holder conflict"
          >
            <div class="js-file-title file-title file-title-flex-parent cursor-default">
              <div class="file-header-content">
                <file-icon :file-name="file.filePath" :size="18" css-classes="gl-mr-2" />
                <strong class="file-title-name">{{ file.filePath }}</strong>
              </div>
              <div class="file-actions d-flex align-items-center gl-ml-auto gl-align-self-start">
                <div v-if="file.type === 'text'" class="btn-group gl-mr-3">
                  <button
                    :class="{ active: file.resolveMode === 'interactive' }"
                    class="btn gl-button"
                    type="button"
                    @click="$root.onClickResolveModeButton(file, 'interactive')"
                  >
                    {{ __('Interactive mode') }}
                  </button>
                  <button
                    :class="{ active: file.resolveMode === 'edit' }"
                    class="btn gl-button"
                    type="button"
                    @click="$root.onClickResolveModeButton(file, 'edit')"
                  >
                    {{ __('Edit inline') }}
                  </button>
                </div>
                <a :href="file.blobPath" class="btn gl-button view-file">
                  <gl-sprintf :message="__('View file @ %{commitSha}')">
                    <template #commitSha>
                      {{ $root.conflictsData.shortCommitSha }}
                    </template>
                  </gl-sprintf>
                </a>
              </div>
            </div>
            <div class="diff-content diff-wrap-lines">
              <div
                v-show="
                  !$root.isParallel && file.resolveMode === 'interactive' && file.type === 'text'
                "
                class="file-content"
              >
                <inline-conflict-lines :file="file" />
              </div>
              <div
                v-show="
                  $root.isParallel && file.resolveMode === 'interactive' && file.type === 'text'
                "
                class="file-content"
              >
                <parallel-conflict-lines :file="file" />
              </div>
              <div v-show="file.resolveMode === 'edit' || file.type === 'text-editor'">
                <diff-file-editor
                  :file="file"
                  :on-accept-discard-confirmation="$root.acceptDiscardConfirmation"
                  :on-cancel-discard-confirmation="$root.cancelDiscardConfirmation"
                />
              </div>
            </div>
          </div>
        </div>
      </div>
    </template>
  </div>
</template>
