<script>
import { GlButton, GlTooltipDirective } from '@gitlab/ui';
import { VALID_DESIGN_FILE_MIMETYPE } from '../../constants';

export default {
  components: {
    GlButton,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    isSaving: {
      type: Boolean,
      required: true,
    },
  },
  methods: {
    openFileUpload() {
      this.$refs.fileUpload.click();
    },
    onFileUploadChange(e) {
      this.$emit('upload', e.target.files);
    },
  },
  VALID_DESIGN_FILE_MIMETYPE,
};
</script>

<template>
  <gl-button
    v-gl-tooltip.hover
    :title="
      s__(
        'DesignManagement|Adding a design with the same filename replaces the file in a new version.',
      )
    "
    :disabled="isSaving"
    :loading="isSaving"
    variant="default"
    size="small"
    @click="openFileUpload"
  >
    {{ s__('DesignManagement|Upload designs') }}
    <input
      ref="fileUpload"
      type="file"
      name="design_file"
      :accept="$options.VALID_DESIGN_FILE_MIMETYPE.mimetype"
      class="hide"
      multiple
      @change="onFileUploadChange"
    />
  </gl-button>
</template>
