<script>
import { GlFormGroup, GlFormSelect } from '@gitlab/ui';
import { __ } from '~/locale';
import { IssuableTypes } from '../../constants';

export const i18n = {
  label: __('Issue Type'),
};

export default {
  i18n,
  components: {
    GlFormGroup,
    GlFormSelect,
  },
  props: {
    formState: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      options: IssuableTypes,
    };
  },
  methods: {
    updateIssueType(type) {
      const { formState } = this;
      this.$emit('update-store-from-state', { ...formState, issue_type: type });
    },
  },
};
</script>

<template>
  <gl-form-group :label="$options.i18n.label" label-class="sr-only" label-for="issuable-type">
    <gl-form-select
      id="issuable-type"
      :value="formState.issue_type"
      :options="options"
      @change="updateIssueType"
    />
  </gl-form-group>
</template>
