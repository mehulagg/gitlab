<script>
import { GlLink, GlIcon } from '@gitlab/ui';
import { mapState } from 'vuex';
import { __ } from '~/locale';

export default {
  name: 'GeoNodeCoreDetails',
  components: {
    GlLink,
    GlIcon,
  },
  props: {
    node: {
      type: Object,
      required: true,
    },
  },
  computed: {
    ...mapState(['primaryVersion', 'primaryRevision']),
    nodeVersion() {
      if (this.node.version == null && this.node.revision == null) {
        return __('Unknown');
      }
      return `${this.node.version} (${this.node.revision})`;
    },
    versionMismatch() {
      return (
        this.node.version !== this.primaryVersion || this.node.revision !== this.primaryRevision
      );
    },
  },
};
</script>

<template>
  <div class="gl-display-grid gl-lg-display-block! geo-node-core-details-grid-columns">
    <div class="gl-display-flex gl-flex-direction-column gl-lg-mb-5">
      <span>{{ __('URL') }}</span>
      <gl-link
        class="gl-text-gray-900 gl-font-weight-bold gl-text-decoration-underline"
        :href="node.url"
        target="_blank"
        >{{ node.url }} <gl-icon name="external-link" class="gl-ml-1"
      /></gl-link>
    </div>
    <div v-if="node.primary" class="gl-display-flex gl-flex-direction-column gl-lg-my-5">
      <span>{{ __('Internal URL') }}</span>
      <span class="gl-font-weight-bold">{{ node.internalUrl }}</span>
    </div>
    <div class="gl-display-flex gl-flex-direction-column gl-lg-mt-5">
      <span>{{ __('GitLab version') }}</span>
      <span :class="{ 'gl-text-red-500': versionMismatch }" class="gl-font-weight-bold">
        {{ nodeVersion }}
      </span>
    </div>
  </div>
</template>
