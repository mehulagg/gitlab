<script>
import { GlTable } from '@gitlab/ui';

export default {
  components: {
    GlTable,
  },
  props: {
    integrations: {
      type: Array,
      required: true,
    },
  },
  fields: [
    {
      key: 'active',
      label: '',
    },
    {
      key: 'name',
      label: 'Integration',
    },
    {
      key: 'description',
      label: 'Description',
    },
    {
      key: 'updated_at',
      label: 'Last edit',
    },
  ],
};
</script>

<template>
  <gl-table :items="integrations" :fields="$options.fields" />
  <!-- </gl-table> -->
</template>
