<script>
import { GlModal, GlFormGroup, GlSprintf } from '@gitlab/ui';
import { sprintf } from '~/locale';

export default {
  components: {
    GlModal,
    GlFormGroup,
    GlSprintf,
  },
  props: {},
  data() {
    return {
      file: null,
    };
  },
  computed: {},
  watch: {},
  methods: {
    show() {
      this.$refs.modal.show();
    },
    hide() {
      this.$refs.modal.hide();
    },
    handleCSVFile(e) {
      this.$emit('change', e.target.files);
      this.file = e.target.files[0];
    },
    handleImport(e) {
      // Prevent modal from closing
      e.preventDefault();
    },
    handleModalClose() {},
  },
};
</script>

<template>
  <gl-modal
    ref="modal"
    size="sm"
    modal-id="import-requirements"
    :title="__('Import requirements')"
    :ok-title="__('Import requirements')"
    @ok="handleImport"
    ok-variant="success"
    ok-only
    @close="handleModalClose"
  >
    <p>
      {{
        __(
          "Your requirements will be imported in the background. Once it's finished, you'll get a confirmation email. ",
        )
      }}
    </p>

    <div>
      <gl-form-group label="Upload file" label-for="import-requirements-file-input">
        <input
          id="import-requirements-file-input"
          ref="fileInput"
          class="gl-mt-3 gl-mb-2 bv-no-focus-ring"
          type="file"
          accept=".csv,text/csv"
          @change="handleCSVFile"
        />
      </gl-form-group>
    </div>

    <p class="text-secondary">
      <gl-sprintf
        :message="
          __(
            'Only data from the column named %{codeStart}title%{codeEnd} can be imported. The maximum file size allowed is 10 MB.',
          )
        "
      >
        <template #code="{ content }">
          <code>{{ content }}</code>
        </template>
      </gl-sprintf>
    </p>
  </gl-modal>
</template>
