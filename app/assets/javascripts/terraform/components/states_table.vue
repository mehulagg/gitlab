<script>
import { GlBadge, GlIcon, GlSprintf, GlTable, GlTooltip } from '@gitlab/ui';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';
import timeagoMixin from '~/vue_shared/mixins/timeago';

export default {
  components: {
    GlBadge,
    GlIcon,
    GlSprintf,
    GlTable,
    GlTooltip,
    TimeAgoTooltip,
  },
  mixins: [timeagoMixin],
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
      <div class="gl-display-flex align-items-center" data-testid="terraform-states-table-name">
        <p class="gl-font-weight-bold gl-m-0 gl-text-gray-900">
          {{ item.name }}
        </p>

        <div v-if="item.lockedAt" id="terraformLockedBadgeContainer" class="gl-m-2">
          <gl-badge id="terraformLockedBadge">
            <gl-icon name="lock" />
            {{ s__('Terraform|Locked') }}
          </gl-badge>

          <gl-tooltip
            container="terraformLockedBadgeContainer"
            placement="right"
            target="terraformLockedBadge"
          >
            <gl-sprintf
              :message="
                s__('Terraform|Locked by %{nameStart}name%{nameEnd} %{timeStart}time%{timeEnd}')
              "
            >
              <template #name>
                {{ item.lockedByUser.name }}
              </template>

              <template #time>
                {{ timeFormatted(item.lockedAt) }}
              </template>
            </gl-sprintf>
          </gl-tooltip>
        </div>
      </div>
    </template>

    <template #cell(updated)="{ item }">
      <p class="gl-m-0" data-testid="terraform-states-table-updated">
        <gl-sprintf
          :message="s__('Terraform|%{nameStart}name%{nameEnd} updated %{timeStart}time%{timeEnd}')"
        >
          <template #name>
            {{ item.latestVersion.createdByUser.name }}
          </template>

          <template #time>
            <time-ago-tooltip :time="item.latestVersion.updatedAt" />
          </template>
        </gl-sprintf>
      </p>
    </template>
  </gl-table>
</template>
