<script>
import { GlButton, GlTooltip } from '@gitlab/ui';
import { __ } from '~/locale';

export default {
  components: {
    GlButton,
    GlTooltip,
  },
  props: {
    mergeCommitsCsvExportPath: {
      required: true,
      type: String,
    },
  },
  strings: {
    listMergeCommitsButtonText: __('List of all merge commits'),
    exportAsCsv: __('Export as CSV'),
    csvSizeLimit: __('(max size 15 MB)'),
  },
  data() {
    return {
      button: null,
    };
  },
  mounted() {
    this.button = this.$refs.button;
  },
};
</script>

<template>
  <div>
    <gl-button
      ref="button"
      :href="mergeCommitsCsvExportPath"
      icon="export"
      class="gl-align-self-center"
    >
      {{ $options.strings.listMergeCommitsButtonText }}
    </gl-button>
    <gl-tooltip v-if="button" :target="button" boundary="viewport" placement="top">
      <p class="gl-my-0">{{ $options.strings.exportAsCsv }}</p>
      <p class="gl-my-0">{{ $options.strings.csvSizeLimit }}</p>
    </gl-tooltip>
  </div>
</template>
