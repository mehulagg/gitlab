<script>
import { GlButton, GlLoadingIcon } from '@gitlab/ui';

import { __ } from '~/locale';

export default {
  components: {
    GlButton,
    GlLoadingIcon,
  },
  props: {
    isSubmitting: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  data() {
    return {
      inputValue: '',
    };
  },
  computed: {
    isSubmitButtonDisabled() {
      return this.inputValue.length === 0 || this.isSubmitting;
    },
    buttonLabel() {
      return this.isSubmitting ? __('Creating epic') : __('Create epic');
    },
  },
  mounted() {
    this.$refs.input.focus();
  },
  methods: {
    onFormSubmit() {
      this.$emit('createEpicFormSubmit', this.inputValue.trim());
    },
    onFormCancel() {
      this.$emit('createEpicFormCancel');
    },
  },
};
</script>

<template>
  <form @submit.prevent="onFormSubmit">
    <input
      ref="input"
      v-model="inputValue"
      :placeholder="__('New epic title')"
      type="text"
      class="form-control"
      @keyup.escape.exact="onFormCancel"
    />
    <div class="add-issuable-form-actions clearfix">
      <gl-button
        :disabled="isSubmitButtonDisabled"
        variant="success"
        type="submit"
        class="float-left"
      >
        {{ buttonLabel }}
        <gl-loading-icon v-if="isSubmitting" :inline="true" />
      </gl-button>
      <gl-button class="float-right" @click="onFormCancel">{{ __('Cancel') }}</gl-button>
    </div>
  </form>
</template>
