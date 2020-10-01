<script>
import { GlDropdown } from '@gitlab/ui';
import { BDropdownForm } from 'bootstrap-vue';

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
  <gl-dropdown class="show" :text="text" :header-text="headerText">
    <b-dropdown-form>
      <slot name="items"></slot>
    </b-dropdown-form>
  </gl-dropdown>
</template>
