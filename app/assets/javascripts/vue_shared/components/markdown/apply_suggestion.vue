<script>
import { GlDropdown, GlDropdownForm, GlFormTextarea, GlButton } from '@gitlab/ui';

export default {
  components: { GlDropdown, GlDropdownForm, GlFormTextarea, GlButton },
  props: {
    disabled: {
      type: Boolean,
      required: false,
      default: false,
    },
    defaultCommitMessage: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      message: null,
    };
  },
  methods: {
    onApply() {
      this.$emit('apply', this.message);
    },
  },
};
</script>

<template>
  <gl-dropdown
    :text="__('Apply suggestion')"
    :disabled="disabled"
    boundary="window"
    :right="true"
    menu-class="gl-w-full!"
  >
    <gl-dropdown-form class="gl-px-4! gl-m-0!">
      <label for="commit-message">{{ __('Commit message') }}</label>
      <gl-form-textarea id="commit-message" v-model="message" :placeholder="defaultCommitMessage" />
      <gl-button
        class="gl-w-auto! gl-mt-3 gl-text-center! float-right"
        category="primary"
        variant="success"
        @click="onApply"
      >
        {{ __('Apply') }}
      </gl-button>
    </gl-dropdown-form>
  </gl-dropdown>
</template>
