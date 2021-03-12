<script>
import { GlIcon, GlPopover, GlLink, GlButton } from '@gitlab/ui';
import { mapGetters, mapState } from 'vuex';
import { GEO_REPLICATION_TYPES_URL } from 'ee/geo_nodes_beta/constants';
import GeoNodeReplicationDetailsDesktop from './geo_node_replication_details_desktop.vue';
import GeoNodeReplicationDetailsMobile from './geo_node_replication_details_mobile.vue';

export default {
  name: 'GeoNodeReplicationDetails',
  components: {
    GlIcon,
    GlPopover,
    GlLink,
    GlButton,
    GeoNodeReplicationDetailsMobile,
    GeoNodeReplicationDetailsDesktop,
  },
  props: {
    node: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      collapsed: false,
    };
  },
  computed: {
    ...mapState(['replicableTypes']),
    ...mapGetters(['verificationInfo', 'syncInfo']),
    replicationItems() {
      const syncInfoData = this.syncInfo(this.node.id);
      const verificationInfoData = this.verificationInfo(this.node.id);

      return this.replicableTypes.map((replicable) => {
        const replicableSyncInfo = syncInfoData.find((r) => r.title === replicable.titlePlural);

        const replicableVerificationInfo = verificationInfoData.find(
          (r) => r.title === replicable.titlePlural,
        );

        return {
          dataTypeTitle: replicable.dataTypeTitle,
          component: replicable.titlePlural,
          syncValues: replicableSyncInfo ? replicableSyncInfo.values : null,
          verificationValues: replicableVerificationInfo ? replicableVerificationInfo.values : null,
        };
      });
    },
    chevronIcon() {
      return this.collapsed ? 'chevron-right' : 'chevron-down';
    },
  },
  methods: {
    collapseSection() {
      this.collapsed = !this.collapsed;
    },
  },
  GEO_REPLICATION_TYPES_URL,
};
</script>

<template>
  <div>
    <div
      class="gl-display-flex gl-align-items-center gl-cursor-pointer gl-py-5 gl-border-b-1 gl-border-b-solid gl-border-b-gray-100 gl-border-t-1 gl-border-t-solid gl-border-t-gray-100"
    >
      <gl-button
        class="gl-mr-3 gl-p-0!"
        category="tertiary"
        variant="confirm"
        :icon="chevronIcon"
        @click="collapseSection"
      >
        {{ __('Replication Details') }}
      </gl-button>
      <gl-icon
        ref="replicationDetails"
        tabindex="0"
        name="question"
        class="gl-text-blue-500 gl-cursor-pointer gl-ml-2"
      />
      <gl-popover
        :target="() => $refs.replicationDetails.$el"
        placement="top"
        triggers="hover focus"
      >
        <p>
          {{ s__('Geo|Geo supports replication of many data types.') }}
        </p>
        <gl-link :href="$options.GEO_REPLICATION_TYPES_URL" target="_blank">{{
          __('Learn more')
        }}</gl-link>
      </gl-popover>
    </div>
    <div v-if="!collapsed">
      <geo-node-replication-details-desktop
        class="gl-display-none gl-md-display-block"
        :replication-items="replicationItems"
      />
      <geo-node-replication-details-mobile
        class="gl-md-display-none!"
        :replication-items="replicationItems"
      />
    </div>
  </div>
</template>
