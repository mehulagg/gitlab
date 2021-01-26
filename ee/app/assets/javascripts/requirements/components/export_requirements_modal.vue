<script>
import { GlModal, GlSprintf } from '@gitlab/ui';
import { __ } from '~/locale';

export default {
  i18n: {
    exportRequirements: __('Export requirements'),
  },
  components: {
    GlModal,
    GlSprintf,
  },
  props: {
    email: {
      type: String,
      required: true,
    },
    requirementCount: {
      type: Number,
      required: true,
    },
  },
  methods: {
    show() {
      this.$refs.modal.show();
    },
    hide() {
      this.$refs.modal.hide();
    },
    handleExport() {
      this.$emit('export');
    },
  },
};
</script>

<template>
  <gl-modal
    ref="modal"
    size="sm"
    modal-id="export-requirements"
    :title="$options.i18n.exportRequirements"
    :ok-title="$options.i18n.exportRequirements"
    ok-variant="success"
    ok-only
    @ok="handleExport"
  >
    <p>
      <gl-sprintf
        :message="
          __(
            '%{requirementCount} requirements have been selected for export. These will be sent to %{email} as an attachment once finished.',
          )
        "
      >
        <template #requirementCount>
          <strong>{{ requirementCount }}</strong>
        </template>
        <template #email>
          <strong>{{ email }}</strong>
        </template>
      </gl-sprintf>
    </p>
  </gl-modal>
</template>
