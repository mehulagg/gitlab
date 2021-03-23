<script>
import { GlIcon, GlLink, GlTable } from '@gitlab/ui';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';

export default {
  components: {
    GlIcon,
    GlLink,
    GlTable,
    TimeAgoTooltip,
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
  <gl-table :items="integrations" :fields="$options.fields">
    <template #cell(active)="{ item }">
      <gl-icon v-if="item.active" name="check" class="gl-text-green-500" />
    </template>

    <template #cell(name)="{ item }">
      <gl-link :href="item.edit_path" class="gl-font-weight-bold">{{ item.name }}</gl-link>
    </template>

    <template #cell(updated_at)="{ item }">
      <time-ago-tooltip v-if="item.updated_at" :time="item.updated_at" />
    </template>
  </gl-table>
</template>
