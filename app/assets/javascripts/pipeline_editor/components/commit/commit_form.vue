<script>
import {
  GlForm,
  GlFormGroup,
  GlFormTextarea,
  GlFormCheckbox,
  GlFormInput,
  GlButton,
} from '@gitlab/ui';

export default {
  components: {
    GlForm,
    GlFormGroup,
    GlFormTextarea,
    GlFormCheckbox,
    GlFormInput,
    GlButton,
  },
  props: {
    defaultBranch: {
      type: String,
      required: true,
    },
    defaultMessage: {
      type: String,
      required: false,
      default: '',
    },
  },
  data() {
    return {
      message: this.defaultMessage,
      branch: this.defaultBranch,
      newMr: false,
    };
  },
  methods: {
    onSubmit() {
      this.$emit('submit', {
        message: this.commitMessage,
        branch: this.branch,
        newMr: this.newMr,
      });
    },
    onReset() {},
  },
};
</script>

<template>
  <div>
    <gl-form @submit.prevent="onSubmit" @reset="onReset">
      <gl-form-group
        id="commit-group"
        :label="__('Commit message')"
        label-cols-sm="2"
        label-for="commit-field"
      >
        <gl-form-textarea
          id="commit-field"
          v-model="commitMessage"
          class="gl-font-monospace!"
          required
          :placeholder="__('Update file')"
        />
      </gl-form-group>
      <gl-form-group
        id="target-branch-group"
        :label="__('Target Branch')"
        label-cols-sm="2"
        label-for="target-branch-field"
      >
        <gl-form-input
          id="target-branch-field"
          v-model="branch"
          class="gl-font-monospace!"
          required
        />
        <gl-form-checkbox v-model="newMr" class="gl-mt-3">
          {{ __('Start a new merge request with these changes') }}
        </gl-form-checkbox>
      </gl-form-group>
      <div
        class="gl-display-flex gl-justify-content-space-between gl-p-5 gl-bg-gray-10 gl-border-t-gray-100 gl-border-t-solid gl-border-t-1"
      >
        <gl-button type="submit" class="js-no-auto-disable" category="primary" variant="success">
          {{ __('Commit changes') }}
        </gl-button>
        <gl-button type="reset" category="secondary" class="gl-mr-3">
          {{ __('Cancel') }}
        </gl-button>
      </div>
    </gl-form>
  </div>
</template>
