<script>
import { GlDropdown } from '@gitlab/ui';

export default {
  name: 'NewProjectItemSelect',
  props: {
    type: {
      type: String,
      required: false,
      default: '',
    },
    path: {
      type: String,
      required: false,
      default: '',
    },
    with_feature_enabled: {
      type: String,
      required: false,
      default: '',
    },
    label: {
      type: String,
      required: false,
      default: '',
    },
  },
  computed: {
    text() {
      return `Create ${this.path} in...`
    },
  },
  components: {
    GlDropdown,
  },
};
</script>

<template>
  <gl-dropdown
    :text="text"
  />
</template>
