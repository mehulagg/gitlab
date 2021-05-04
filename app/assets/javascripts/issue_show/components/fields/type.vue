<script>
import { GlFormGroup, GlDropdown, GlDropdownItem } from '@gitlab/ui';
import { capitalize } from 'lodash';
import { __ } from '~/locale';
import { IssuableTypes } from '../../constants';

export const i18n = {
  label: __('Issue Type'),
};

export default {
  i18n,
  IssuableTypes,
  components: {
    GlFormGroup,
    GlDropdown,
    GlDropdownItem,
  },
  props: {
    formState: {
      type: Object,
      required: true,
    },
  },
  computed: {
    dropdownText() {
      const {
        formState: { issue_type },
      } = this;
      return capitalize(issue_type);
    },
  },
  methods: {
    updateIssueType(value) {
      const { formState } = this;
      this.$emit('update-store-from-state', { ...formState, issue_type: value });
    },
  },
};
</script>

<template>
  <gl-form-group :label="$options.i18n.label" label-class="sr-only" label-for="issuable-type">
    <gl-dropdown
      id="issuable-type"
      :aria-labelledby="$options.i18n.label"
      :text="dropdownText"
      :header-text="$options.i18n.label"
      class="gl-w-full"
      toggle-class="dropdown-menu-toggle"
    >
      <gl-dropdown-item
        v-for="type in $options.IssuableTypes"
        :key="type.value"
        :is-checked="formState.issue_type === type.value"
        is-check-item
        @click="updateIssueType(type.value)"
      >
        {{ type.text }}
      </gl-dropdown-item>
    </gl-dropdown>
  </gl-form-group>
</template>
