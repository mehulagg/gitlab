<script>
import { GlButtonGroup, GlButton, GlDropdown, GlFormCheckbox } from '@gitlab/ui';
import { mapActions, mapGetters, mapState } from 'vuex';
import { SETTINGS_DROPDOWN } from '../i18n';

export default {
  i18n: SETTINGS_DROPDOWN,
  components: {
    GlButtonGroup,
    GlButton,
    GlDropdown,
    GlFormCheckbox,
  },
  data() {
    return {
      isReloading: false,
      newSettings: {
        renderTreeList: null,
        viewDiffsFileByFile: null,
        showWhitespace: null,
        isInlineView: null,
      },
    };
  },
  computed: {
    ...mapGetters('diffs', ['isInlineView']),
    ...mapState('diffs', ['renderTreeList', 'showWhitespace', 'viewDiffsFileByFile']),
  },
  mounted() {
    this.newSettings = {
      renderTreeList: this.renderTreeList,
      viewDiffsFileByFile: this.viewDiffsFileByFile,
      showWhitespace: this.showWhitespace,
      isInlineView: this.isInlineView,
    };
  },
  methods: {
    ...mapActions('diffs', [
      'setInlineDiffViewType',
      'setParallelDiffViewType',
      'setRenderTreeList',
      'setShowWhitespace',
      'setFileByFile',
    ]),
    updateSetting(key, value) {
      this.newSettings[key] = value;
    },
    saveSettings() {
      this.isReloading = true;

      if (this.newSettings.renderTreeList !== this.renderTreeList) {
        this.setRenderTreeList(this.newSettings.renderTreeList);
      }

      if (this.newSettings.viewDiffsFileByFile !== this.viewDiffsFileByFile) {
        this.setFileByFile({ fileByFile: this.newSettings.viewDiffsFileByFile });
      }

      if (this.newSettings.showWhitespace !== this.showWhitespace) {
        this.setShowWhitespace(this.newSettings.showWhitespace);
      }

      if (this.newSettings.isInlineView) {
        this.setInlineDiffViewType();
      } else {
        this.setParallelDiffViewType();
      }

      window.location.reload();
    },
  },
};
</script>

<template>
  <gl-dropdown
    icon="settings"
    :text="__('Diff view settings')"
    :text-sr-only="true"
    toggle-class="js-show-diff-settings"
    right
  >
    <div class="gl-px-3">
      <span class="gl-font-weight-bold gl-display-block gl-mb-2">{{ __('File browser') }}</span>
      <gl-button-group class="gl-display-flex">
        <gl-button
          :class="{ selected: !newSettings.renderTreeList }"
          class="gl-w-half js-list-view"
          @click="updateSetting('renderTreeList', false)"
        >
          {{ __('List view') }}
        </gl-button>
        <gl-button
          :class="{ selected: newSettings.renderTreeList }"
          class="gl-w-half js-tree-view"
          @click="updateSetting('renderTreeList', true)"
        >
          {{ __('Tree view') }}
        </gl-button>
      </gl-button-group>
    </div>
    <div class="gl-mt-3 gl-px-3">
      <span class="gl-font-weight-bold gl-display-block gl-mb-2">{{ __('Compare changes') }}</span>
      <gl-button-group class="gl-display-flex js-diff-view-buttons">
        <gl-button
          id="inline-diff-btn"
          :class="{ selected: newSettings.isInlineView }"
          class="gl-w-half js-inline-diff-button"
          data-view-type="inline"
          @click="updateSetting('isInlineView', true)"
        >
          {{ __('Inline') }}
        </gl-button>
        <gl-button
          id="parallel-diff-btn"
          :class="{ selected: !newSettings.isInlineView }"
          class="gl-w-half js-parallel-diff-button"
          data-view-type="parallel"
          @click="updateSetting('isInlineView', false)"
        >
          {{ __('Side-by-side') }}
        </gl-button>
      </gl-button-group>
    </div>
    <gl-form-checkbox
      v-model="newSettings.showWhitespace"
      data-testid="show-whitespace"
      class="gl-mt-3 gl-ml-3"
    >
      {{ $options.i18n.whitespace }}
    </gl-form-checkbox>
    <gl-form-checkbox
      v-model="newSettings.viewDiffsFileByFile"
      data-testid="file-by-file"
      class="gl-ml-3 gl-mb-0"
    >
      {{ $options.i18n.fileByFile }}
    </gl-form-checkbox>
    <div class="gl-px-3">
      <gl-button :loading="isReloading" variant="confirm" @click="saveSettings">
        {{ __('Reload to apply') }}
      </gl-button>
    </div>
  </gl-dropdown>
</template>
