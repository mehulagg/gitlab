<script>
import { GlPopover, GlLink, GlIcon } from '@gitlab/ui';
import { __ } from '~/locale';
import {
  REPLICATION_STATUS_CLASS,
  REPLICATION_STATUS_ICON,
  REPLICATION_PAUSE_URL,
} from '../constants';

export default {
  components: {
    GlIcon,
    GlPopover,
    GlLink,
  },
  props: {
    node: {
      type: Object,
      required: true,
    },
  },
  computed: {
    replicationStatusCssClass() {
      return this.node.enabled
        ? REPLICATION_STATUS_CLASS.enabled
        : REPLICATION_STATUS_CLASS.disabled;
    },
    nodeReplicationStatusIcon() {
      return this.node.enabled ? REPLICATION_STATUS_ICON.enabled : REPLICATION_STATUS_ICON.disabled;
    },
    nodeReplicationStatusText() {
      return this.node.enabled ? __('Replication enabled') : __('Replication paused');
    },
  },
  REPLICATION_PAUSE_URL,
};
</script>

<template>
  <div class="mt-2 detail-section-item">
    <div class="gl-text-gray-500 node-detail-title">{{ s__('GeoNodes|Replication status') }}</div>
    <div class="gl-display-flex gl-align-items-center">
      <div
        :class="replicationStatusCssClass"
        class="rounded-pill gl-display-inline-flex gl-align-items-center px-2 gl-py-2 gl-my-2"
      >
        <gl-icon :name="nodeReplicationStatusIcon" />
        <strong class="status-text gl-ml-2"> {{ nodeReplicationStatusText }} </strong>
      </div>
      <gl-icon
        ref="replicationStatusHelp"
        tabindex="0"
        name="question"
        class="gl-text-blue-600 gl-ml-2 gl-cursor-pointer"
      />
      <gl-popover :target="() => $refs.replicationStatusHelp.$el" placement="top">
        <p>{{ __('Geo nodes are paused using a command run on the node') }}</p>
        <gl-link
          class="gl-mt-5 gl-font-sm"
          :href="$options.REPLICATION_PAUSE_URL"
          target="_blank"
          >{{ __('More Information') }}</gl-link
        >
      </gl-popover>
    </div>
  </div>
</template>
