<script>
import { GlBadge, GlIcon, GlLink, GlSprintf, GlTable, GlTooltip } from '@gitlab/ui';
import { s__ } from '~/locale';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';
import timeagoMixin from '~/vue_shared/mixins/timeago';

import CiBadge from '~/vue_shared/components/ci_badge_link.vue';

export default {
  components: {
    GlBadge,
    GlIcon,
    GlLink,
    GlSprintf,
    GlTable,
    GlTooltip,
    TimeAgoTooltip,

    CiBadge,
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
          label: s__('Terraform|Name'),
        },
        {
          key: 'pipeline',
          label: s__('Terraform|Pipeline'),
        },
        {
          key: 'updated',
          label: s__('Terraform|Commit details'),
        },
      ];
    },
  },
  methods: {
    createdByUserName(item) {
      return item.latestVersion?.createdByUser?.name;
    },
    lockedByUserName(item) {
      return item.lockedByUser?.name || s__('Terraform|Unknown User');
    },
    pipelineDetailedStatus(item) {
      return item.latestVersion?.job?.detailedStatus;
    },
    pipelineID(item) {
      return item.latestVersion?.job?.pipeline?.iid;
    },
    pipelinePath(item) {
      return item.latestVersion?.job?.pipeline?.path;
    },
    updatedTime(item) {
      return item.latestVersion?.updatedAt || item.updatedAt;
    },
  },
};
</script>

<template>
  <gl-table
    fixed
    stacked="md"
    :items="states"
    :fields="fields"
    data-testid="terraform-states-table"
  >
    <template #cell(name)="{ item }">
      <div
        class="gl-display-flex align-items-center gl-justify-content-end gl-justify-content-md-start"
        data-testid="terraform-states-table-name"
      >
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
                {{ lockedByUserName(item) }}
              </template>

              <template #timeAgo>
                {{ timeFormatted(item.lockedAt) }}
              </template>
            </gl-sprintf>
          </gl-tooltip>
        </div>
      </div>
    </template>

    <template #cell(pipeline)="{ item }">
      <div v-if="pipelineID(item)">
        <gl-link v-if="pipelineID(item)" :href="pipelinePath(item)" target="_blank">
          #{{ pipelineID(item) }}
        </gl-link>

        <div>
          <ci-badge
            :status="pipelineDetailedStatus(item)"
            :show-text="true"
            :icon-classes="'gl-vertical-align-middle!'"
          />
        </div>
      </div>
    </template>

    <template #cell(updated)="{ item }">
      <p class="gl-m-0" data-testid="terraform-states-table-updated">
        <gl-sprintf :message="s__('Terraform|%{user} updated %{timeAgo}')">
          <template #user>
            <span v-if="item.latestVersion">
              {{ createdByUserName(item) }}
            </span>
          </template>

          <template #timeAgo>
            <time-ago-tooltip :time="updatedTime(item)" />
          </template>
        </gl-sprintf>
      </p>
    </template>
  </gl-table>
</template>
