<script>
import { BDropdownForm } from 'bootstrap-vue';
import { GlDropdown } from '@gitlab/ui';

export default {
  components: {
    BDropdownForm,
    GlDropdown,
  },
  props: {
    headerText: {
      type: String,
      required: true,
    },
    text: {
      type: String,
      required: true,
    },
  },
};
</script>

<template>
  <gl-dropdown data-test-id="dropdown" class="show" :text="text" :header-text="headerText">
    <b-dropdown-form data-test-id="dropdown-form">
      <slot name="items"></slot>
    </b-dropdown-form>
  </gl-dropdown>
</template>
