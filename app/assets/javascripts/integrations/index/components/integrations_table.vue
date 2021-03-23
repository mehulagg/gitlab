<script>
import { GlIcon, GlLink, GlTable } from '@gitlab/ui';
import { __ } from '~/locale';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';

export default {
  components: {
    GlIcon,
    GlLink,
    GlTable,
    TimeAgoTooltip,
  },
  props: {
    active: {
      type: Boolean,
      required: false,
      default: false,
    },
    integrations: {
      type: Array,
      required: true,
    },
  },
  computed: {
    fields() {
      return [
        {
          key: 'active',
          label: '',
        },
        {
          key: 'name',
          label: __('Integration'),
        },
        {
          key: 'description',
          label: __('Description'),
        },
        this.active
          ? {
              key: 'updated_at',
              label: __('Last updated'),
            }
          : {},
      ];
    },
  },
};
</script>

<template>
  <gl-table :items="integrations" :fields="fields">
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
