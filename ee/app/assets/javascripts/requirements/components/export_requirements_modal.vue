<script>
import { GlModal, GlSprintf } from '@gitlab/ui';

export default {
  components: {
    GlModal,
    GlSprintf
  },
  props: {
    email: {
      type: String,
      required: true,
    },
    requirementCount: {
      type: Number,
      required: true,
    }
  },
  methods: {
    show() {
      this.$refs.modal.show();
    },
    hide() {
      this.$refs.modal.hide();
    },
    handleExport() {
      console.log('Handle export clicked');
    },
  },
};
</script>

<template>
  <gl-modal
    ref="modal"
    size="sm"
    modal-id="export-requirements"
    :title="__('Export requirements')"
    :ok-title="__('Export requirements')"
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
