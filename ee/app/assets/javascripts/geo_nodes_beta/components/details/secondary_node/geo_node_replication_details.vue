<script>
import { GlIcon, GlPopover, GlLink } from '@gitlab/ui';
import { mapGetters } from 'vuex';
import GeoNodeProgressBar from 'ee/geo_nodes_beta/components/details/geo_node_progress_bar.vue';
import { HELP_INFO_URL } from 'ee/geo_nodes_beta/constants';

export default {
  name: 'GeoNodeReplicationDetails',
  components: {
    GlIcon,
    GlPopover,
    GlLink,
    GeoNodeProgressBar,
  },
  props: {
    node: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      showSection: true,
    };
  },
  computed: {
    ...mapGetters(['verificationInfo', 'syncInfo']),
    replicationItems() {
      const syncInfoData = this.syncInfo(this.node.id);
      const verificationInfoData = this.verificationInfo(this.node.id);

      return syncInfoData.map((replicable) => {
        const replicableVerificationInfo = verificationInfoData.find(
          (r) => r.title === replicable.title,
        );

        return {
          dataTypeTitle: replicable.dataTypeTitle,
          component: replicable.title,
          syncValues: replicable.values,
          verificationValues: replicableVerificationInfo ? replicableVerificationInfo.values : null,
        };
      });
    },
    chevronIcon() {
      return this.showSection ? 'chevron-down' : 'chevron-right';
    },
  },
  HELP_INFO_URL,
};
</script>

<template>
  <div>
    <div
      class="gl-display-flex gl-align-items-center gl-cursor-pointer gl-py-5 gl-border-b-1 gl-border-b-solid gl-border-b-gray-100 gl-border-t-1 gl-border-t-solid gl-border-t-gray-100"
    >
      <gl-icon class="gl-text-blue-500 gl-mr-3" :name="chevronIcon" />
      <span class="gl-text-blue-500">{{ __('Replication Details') }}</span>
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
          {{ __('Lorem ipsum dolor sit amet, consectetur adipiscing elit.') }}
        </p>
        <gl-link href="#" target="_blank">{{ __('Learn more') }}</gl-link>
      </gl-popover>
    </div>
    <div
      class="gl-display-grid geo-node-replication-details-grid-columns gl-bg-gray-10 gl-p-5 gl-border-b-1 gl-border-b-solid gl-border-b-gray-100"
    >
      <span class="gl-font-weight-bold gl-display-none gl-md-display-block">{{
        __('Data type')
      }}</span>
      <span class="gl-font-weight-bold">{{ __('Component') }}</span>
      <span class="gl-font-weight-bold gl-display-block gl-md-display-none!">{{
        __('Status')
      }}</span>
      <span class="gl-font-weight-bold gl-display-none gl-md-display-block">{{
        __('Synchronization status')
      }}</span>
      <div class="gl-display-none gl-md-display-flex gl-align-items-center">
        <span class="gl-font-weight-bold">{{ __('Verification status') }}</span>
        <gl-icon
          ref="verificationStatus"
          tabindex="0"
          name="question"
          class="gl-text-blue-500 gl-cursor-pointer gl-ml-2"
        />
        <gl-popover
          :target="() => $refs.verificationStatus.$el"
          placement="top"
          triggers="hover focus"
        >
          <p>
            {{ __('Replicated data is verified with the secondary node(s) using checksums') }}
          </p>
          <gl-link :href="$options.HELP_INFO_URL" target="_blank">{{ __('Learn more') }}</gl-link>
        </gl-popover>
      </div>
    </div>
    <div
      v-for="item in replicationItems"
      :key="item.component"
      class="gl-display-grid geo-node-replication-details-grid-columns gl-p-5 gl-border-b-1 gl-border-b-solid gl-border-b-gray-100"
    >
      <span class="gl-mr-5 gl-display-none gl-md-display-block">{{ item.dataTypeTitle }}</span>
      <span class="gl-mr-5">{{ item.component }}</span>
      <div class="gl-mr-5 gl-display-none gl-md-display-block">
        <geo-node-progress-bar
          v-if="item.syncValues"
          :title="`${item.component} synced`"
          :values="item.syncValues"
        />
        <span v-else class="gl-text-gray-400 gl-font-sm">{{ __('N/A') }}</span>
      </div>
      <div class="gl-display-none gl-md-display-block">
        <geo-node-progress-bar
          v-if="item.verificationValues"
          :title="`${item.component} synced`"
          :values="item.verificationValues"
        />
        <span v-else class="gl-text-gray-400 gl-font-sm">{{ __('N/A') }}</span>
      </div>
      <div class="gl-display-block gl-md-display-none!">
        <div class="gl-mb-5 gl-display-flex gl-flex-direction-column">
          <span class="gl-font-sm gl-mb-3">{{ __('Synchronization status') }}</span>
          <geo-node-progress-bar
            v-if="item.syncValues"
            :title="`${item.component} synced`"
            :values="item.syncValues"
          />
          <span v-else class="gl-text-gray-400 gl-font-sm">{{ __('N/A') }}</span>
        </div>
        <div class="gl-display-flex gl-flex-direction-column">
          <span class="gl-font-sm gl-mb-3">{{ __('Verification status') }}</span>
          <geo-node-progress-bar
            v-if="item.verificationValues"
            :title="`${item.component} synced`"
            :values="item.verificationValues"
          />
          <span v-else class="gl-text-gray-400 gl-font-sm">{{ __('N/A') }}</span>
        </div>
      </div>
    </div>
  </div>
</template>
