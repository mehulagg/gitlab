<script>
import { GlBadge, GlIcon, GlSprintf, GlTable } from '@gitlab/ui';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';

export default {
  components: {
    GlBadge,
    GlIcon,
    GlSprintf,
    GlTable,
    TimeAgoTooltip,
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
          thClass: 'gl-display-none',
        },
        {
          key: 'updated',
          thClass: 'gl-display-none',
          tdClass: 'gl-text-right',
        },
      ];
    },
  },
};
</script>

<template>
  <gl-table :items="states" :fields="fields" data-testid="terraform-states-table">
    <template #cell(name)="{ item }">
      <strong>
        {{ item.name }}
      </strong>

      <gl-badge v-if="item.lockedAt">
        <gl-icon name="lock" />
        {{ s__('Terraform|Locked') }}
      </gl-badge>
    </template>

    <template #cell(updated)="{ item }">
      <gl-sprintf :message="s__('Terraform|updated %{timeStart}time%{timeEnd}')">
        <template #time>
          <time-ago-tooltip :time="item.updatedAt" />
        </template>
      </gl-sprintf>
    </template>
  </gl-table>
</template>
