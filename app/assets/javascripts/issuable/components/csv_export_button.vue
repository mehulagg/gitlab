<script>
import {
  GlButton,
  GlModal,
  GlTooltipDirective,
  GlModalDirective,
  GlSafeHtmlDirective as SafeHtml,
  GlSprintf,
} from '@gitlab/ui';
import exportImportIllustration from '@gitlab/svgs/dist/illustrations/export-import.svg';
import { __, n__ } from '~/locale';
export default {
  name: 'CsvExportButton',
  components: {
    GlButton,
    GlModal,
    GlSprintf,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
    GlModal: GlModalDirective,
    SafeHtml,
  },
  inject: {
    issuableType: {
      default: '',
    },
    issuableCount: {
      default: null,
    },
    email: {
      default: '',
    },
    exportCsvPath: {
      default: '',
    },
  },
  data() {
    return {};
  },
  computed: {
    modalId() {
      return `${this.issuableType}-export-modal`;
    },
    exportBtnName() {
      return this.issuableType === 'issues' ? __('Export issues') : __('Export merge requests');
    },
  },
  exportImportIllustration,
};
</script>

<template>
  <div style="display: contents">
    <gl-button v-gl-tooltip="{ title: __('Export as CSV') }" v-gl-modal="modalId" icon="export" />
    <gl-modal :modal-id="modalId">
      <template #modal-title>
        <h3>title goes here</h3>
        <div
          class="svg-content import-export-svg-container"
          v-safe-html="$options.exportImportIllustration"
        ></div>
      </template>
      <div v-if="issuableCount > -1" class="modal-subheader">
        <strong class="gl-m-3">
          <gl-sprintf
            v-if="issuableType === 'issues'"
            :message="n__('1 issue selected', '%d issues selected', issuableCount)"
          >
            <template #issuableCount>{{ issuableCount }}</template>
          </gl-sprintf>
          <gl-sprintf
            v-else
            :message="n__('1 merge request selected', '%d merge request selected', issuableCount)"
          >
            <template #issuableCount>{{ issuableCount }}</template>
          </gl-sprintf>
        </strong>
      </div>
      <div class="modal-text">
        <gl-sprintf
          :message="
            __(
              `The CSV export will be created in the background. Once finished, it will be sent to %{strongStart}${email}%{strongEnd} in an attachment.`,
            )
          "
        >
          <template #strong="{ content }">
            <strong>{{ content }}</strong>
          </template>
        </gl-sprintf>
      </div>
      <template #modal-footer>
        <gl-button category="primary" variant="success" :href="exportCsvPath">{{
          exportBtnName
        }}</gl-button>
      </template>
    </gl-modal>
  </div>
</template>
