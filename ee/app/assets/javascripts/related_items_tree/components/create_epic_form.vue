<script>
import { mapState } from 'vuex';

import { GlButton } from '@gitlab/ui';

import { __ } from '~/locale';

export default {
  components: {
    GlButton,
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
    ...mapState(['parentItem']),
    isSubmitButtonDisabled() {
      return this.inputValue.length === 0 || this.isSubmitting;
    },
    buttonLabel() {
      return this.isSubmitting ? __('Creating epic') : __('Create epic');
    },
  },
  mounted() {
    this.$nextTick()
      .then(() => {
        this.$refs.input.focus();
      })
      .catch(() => {});
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
      :placeholder="
        parentItem.confidential ? __('New confidential epic title ') : __('New epic title')
      "
      type="text"
      class="form-control"
      @keyup.escape.exact="onFormCancel"
    />
    <div class="add-issuable-form-actions clearfix">
      <gl-button
        :disabled="isSubmitButtonDisabled"
        :loading="isSubmitting"
        variant="success"
        category="primary"
        type="submit"
        class="float-left"
      >
        {{ buttonLabel }}
      </gl-button>
      <gl-button class="float-right" @click="onFormCancel">{{ __('Cancel') }}</gl-button>
    </div>
  </form>
</template>
