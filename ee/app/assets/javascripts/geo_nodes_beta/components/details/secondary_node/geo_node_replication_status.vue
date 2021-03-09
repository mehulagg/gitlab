<script>
import { GlIcon, GlPopover, GlLink } from '@gitlab/ui';
import { REPLICATION_STATUS_UI, REPLICATION_PAUSE_URL } from 'ee/geo_nodes_beta/constants';

export default {
  name: 'GeoNodeReplicationStatus',
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
    replicationStatusUi() {
      return this.node.enabled ? REPLICATION_STATUS_UI.enabled : REPLICATION_STATUS_UI.disabled;
    },
  },
  REPLICATION_PAUSE_URL,
};
</script>

<template>
  <div class="gl-display-flex gl-align-items-center">
    <gl-icon :name="replicationStatusUi.icon" :class="replicationStatusUi.color" />
    <span class="gl-font-weight-bold" :class="replicationStatusUi.color">{{
      replicationStatusUi.text
    }}</span>
    <gl-icon
      ref="replicationStatus"
      tabindex="0"
      name="question"
      class="gl-text-blue-500 gl-cursor-pointer gl-ml-2"
    />
    <gl-popover :target="() => $refs.replicationStatus.$el" placement="top" triggers="hover focus">
      <p>
        {{ __('Geo nodes are paused using a command run on the node') }}
      </p>
      <gl-link :href="$options.REPLICATION_PAUSE_URL" target="_blank">{{
        __('Learn more')
      }}</gl-link>
    </gl-popover>
  </div>
</template>
