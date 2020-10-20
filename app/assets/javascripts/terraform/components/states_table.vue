<script>
import { GlTable } from '@gitlab/ui';
import { s__ } from '~/locale';

export default {
  components: {
    GlTable,
  },
  props: {
    states: {
      required: true,
      type: Array,
    },
  },
  computed: {
    fields() {
      return [
        {
          key: 'name',
          label: s__('Terraform|Name'),
          thClass: 'gl-display-none',
        },
      ];
    },
  },
};
</script>

<template>
  <gl-table :items="states" :fields="fields" />
</template>
