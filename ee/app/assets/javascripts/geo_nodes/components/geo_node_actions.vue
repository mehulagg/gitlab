<script>
import { GlIcon, GlButton, GlTooltipDirective } from '@gitlab/ui';
import { __, s__ } from '~/locale';
import eventHub from '../event_hub';
import { NODE_ACTIONS } from '../constants';

export default {
  components: {
    GlIcon,
    GlButton,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    node: {
      type: Object,
      required: true,
    },
    nodeActionsAllowed: {
      type: Boolean,
      required: true,
    },
    nodeEditAllowed: {
      type: Boolean,
      required: true,
    },
    nodeRemovalAllowed: {
      type: Boolean,
      required: true,
    },
    nodeMissingOauth: {
      type: Boolean,
      required: true,
    },
  },
  computed: {
    isSecondaryNode() {
      return !this.node.primary;
    },
    disabledRemovalTooltip() {
      return this.nodeRemovalAllowed
        ? ''
        : s__('Geo Nodes|Cannot remove a primary node if there is a secondary node');
    },
  },
  methods: {
    onToggleNode() {
      eventHub.$emit('showNodeActionModal', {
        actionType: NODE_ACTIONS.TOGGLE,
        node: this.node,
        modalMessage: s__('GeoNodes|Pausing replication stops the sync process. Are you sure?'),
        modalActionLabel: this.nodeToggleLabel,
        modalTitle: __('Pause replication'),
      });
    },
    onRemoveSecondaryNode() {
      eventHub.$emit('showNodeActionModal', {
        actionType: NODE_ACTIONS.REMOVE,
        node: this.node,
        modalKind: 'danger',
        modalMessage: s__(
          'GeoNodes|Removing a Geo secondary node stops the synchronization to that node. Are you sure?',
        ),
        modalActionLabel: __('Remove node'),
        modalTitle: __('Remove secondary node'),
      });
    },
    onRemovePrimaryNode() {
      eventHub.$emit('showNodeActionModal', {
        actionType: NODE_ACTIONS.REMOVE,
        node: this.node,
        modalKind: 'danger',
        modalMessage: s__(
          'GeoNodes|Removing a Geo primary node stops the synchronization to all nodes. Are you sure?',
        ),
        modalActionLabel: __('Remove node'),
        modalTitle: __('Remove primary node'),
      });
    },
    onRepairNode() {
      eventHub.$emit('repairNode', this.node);
    },
  },
};
</script>

<template>
  <div
    data-testid="nodeActions"
    class="gl-display-flex gl-align-items-center gl-justify-content-end gl-flex-direction-column gl-sm-flex-direction-row gl-mx-5 gl-sm-mx-0"
  >
    <gl-button
      v-if="isSecondaryNode"
      :href="node.geoProjectsUrl"
      class="gl-mx-2 gl-mt-5 gl-sm-mt-0 gl-w-full gl-sm-w-auto"
      target="_blank"
    >
      <span class="gl-display-flex gl-align-items-center">
        <gl-icon v-if="!node.current" name="external-link" class="gl-mr-2" />
        {{ __('Open projects') }}
      </span>
    </gl-button>
    <template v-if="nodeActionsAllowed">
      <gl-button
        v-if="nodeMissingOauth"
        class="gl-mx-2 gl-mt-5 gl-sm-mt-0 gl-w-full gl-sm-w-auto"
        @click="onRepairNode"
      >
        {{ s__('Repair authentication') }}
      </gl-button>
      <gl-button
        v-if="nodeEditAllowed"
        :href="node.editPath"
        class="gl-mx-2 gl-mt-5 gl-sm-mt-0 gl-w-full gl-sm-w-auto"
      >
        {{ __('Edit') }}
      </gl-button>
      <gl-button
        v-if="isSecondaryNode"
        data-testid="removeButton"
        variant="danger"
        class="gl-mx-2 gl-mt-5 gl-sm-mt-0 gl-w-full gl-sm-w-auto"
        :disabled="!nodeRemovalAllowed"
        @click="onRemoveSecondaryNode"
      >
        {{ __('Remove') }}
      </gl-button>
      <div
        v-gl-tooltip.hover
        name="disabledRemovalTooltip"
        class="gl-mx-2 gl-mt-5 gl-sm-mt-0 gl-w-full gl-sm-w-auto"
        :title="disabledRemovalTooltip"
      >
        <gl-button
          v-if="!isSecondaryNode"
          variant="danger"
          class="gl-w-full"
          :disabled="!nodeRemovalAllowed"
          @click="onRemovePrimaryNode"
        >
          {{ __('Remove') }}
        </gl-button>
      </div>
    </template>
  </div>
</template>
