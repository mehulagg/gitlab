<script>
import { GlIcon, GlPopover, GlLink, GlButton } from '@gitlab/ui';
import { mapGetters, mapState } from 'vuex';
import { GEO_REPLICATION_TYPES_URL } from 'ee/geo_nodes_beta/constants';
import { s__, __ } from '~/locale';

export default {
  name: 'GeoNodeReplicationDetails',
  i18n: {
    replicationDetailsDesktop: s__('Geo|Replication Details Desktop'),
    replicationDetailsMobile: s__('Geo|Replication Details Mobile'),
    replicationDetails: s__('Geo|Replication Details'),
    popoverText: s__('Geo|Geo supports replication of many data types.'),
    learnMore: __('Learn more'),
  },
  components: {
    GlIcon,
    GlPopover,
    GlLink,
    GlButton,
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
        {{ $options.i18n.replicationDetails }}
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
          {{ $options.i18n.popoverText }}
        </p>
        <gl-link :href="$options.GEO_REPLICATION_TYPES_URL" target="_blank">{{
          $options.i18n.learnMore
        }}</gl-link>
      </gl-popover>
    </div>
    <div v-if="!collapsed">
      <span class="gl-display-none gl-md-display-block" data-testid="replication-details-desktop">{{
        $options.i18n.replicationDetailsDesktop
      }}</span>
      <span class="gl-md-display-none!" data-testid="replication-details-mobile">{{
        $options.i18n.replicationDetailsMobile
      }}</span>
    </div>
  </div>
</template>
