<script>
import {
  GlBadge,
  GlIcon,
  GlDropdown,
  GlDropdownDivider,
  GlDropdownItem,
  GlDropdownSectionHeader,
  GlSprintf,
  GlTable,
  GlTooltip,
} from '@gitlab/ui';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';
import timeagoMixin from '~/vue_shared/mixins/timeago';

export default {
  components: {
    GlBadge,
    GlIcon,
    GlDropdown,
    GlDropdownDivider,
    GlDropdownItem,
    GlDropdownSectionHeader,
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
        {
          key: 'actions',
          thClass: 'gl-display-none',
          tdClass: 'gl-w-10',
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

        <div v-if="item.lockedAt" id="terraformLockedBadgeContainer" class="gl-mx-2">
          <gl-badge id="terraformLockedBadge">
            <gl-icon name="lock" />
            {{ s__('Terraform|Locked') }}
          </gl-badge>

          <gl-tooltip
            container="terraformLockedBadgeContainer"
            placement="right"
            target="terraformLockedBadge"
          >
            <gl-sprintf :message="s__('Terraform|Locked by %{user} %{timeAgo}')">
              <template #user>
                {{ item.lockedByUser.name }}
              </template>

              <template #timeAgo>
                {{ timeFormatted(item.lockedAt) }}
              </template>
            </gl-sprintf>
          </gl-tooltip>
        </div>
      </div>
    </template>

    <template #cell(updated)="{ item }">
      <p class="gl-m-0" data-testid="terraform-states-table-updated">
        <gl-sprintf :message="s__('Terraform|%{user} updated %{timeAgo}')">
          <template #user>
            <span v-if="item.latestVersion">
              {{ item.latestVersion.createdByUser.name }}
            </span>
          </template>

          <template #timeAgo>
            <span v-if="item.latestVersion">
              <time-ago-tooltip :time="item.latestVersion.updatedAt" />
            </span>

            <span v-else>
              <time-ago-tooltip :time="item.updatedAt" />
            </span>
          </template>
        </gl-sprintf>
      </p>
    </template>

    <template #cell(actions)="{ item }">
      <gl-dropdown icon="ellipsis_v" right>
        <gl-dropdown-section-header>
          {{ s__('Terraform|Actions') }}
        </gl-dropdown-section-header>

        <gl-dropdown-item icon-name="download">
          {{ s__('Terraform|Download latest (JSON)') }}
        </gl-dropdown-item>

        <gl-dropdown-item v-if="item.lockedAt" icon-name="lock-open">
          {{ s__('Terraform|UnLock') }}
        </gl-dropdown-item>

        <gl-dropdown-item v-else icon-name="lock">
          {{ s__('Terraform|Lock') }}
        </gl-dropdown-item>

        <gl-dropdown-divider />

        <gl-dropdown-item icon-name="remove-all">
          {{ s__('Terraform|Remove state file and versions') }}
        </gl-dropdown-item>
      </gl-dropdown>
    </template>
  </gl-table>
</template>
