<script>
import { GlLink, GlButton, GlLoadingIcon } from '@gitlab/ui';
import { mapActions, mapState } from 'vuex';
import { s__, __ } from '~/locale';
import { GEO_INFO_URL } from '../constants';
import GeoNodes from './geo_nodes.vue';
import GeoNodesEmptyState from './geo_nodes_empty_state.vue';

export default {
  name: 'GeoNodesBetaApp',
  i18n: {
    geoSites: s__('Geo|Geo sites'),
    helpText: s__(
      'Geo|With GitLab Geo, you can install a special read-only and replicated instance anywhere.',
    ),
    learnMore: __('Learn more'),
    addSite: s__('Geo|Add site'),
  },
  components: {
    GlLink,
    GlButton,
    GlLoadingIcon,
    GeoNodes,
    GeoNodesEmptyState,
  },
  props: {
    newNodeUrl: {
      type: String,
      required: true,
    },
    geoNodesEmptyStateSvg: {
      type: String,
      required: true,
    },
  },
  computed: {
    ...mapState(['nodes', 'isLoading']),
    noNodes() {
      return !this.nodes || this.nodes.length === 0;
    },
  },
  created() {
    this.fetchNodes();
  },
  methods: {
    ...mapActions(['fetchNodes']),
  },
  GEO_INFO_URL,
};
</script>

<template>
  <section>
    <h3>{{ $options.i18n.geoSites }}</h3>
    <div
      class="gl-display-flex gl-flex-direction-column gl-md-flex-direction-row gl-md-align-items-center gl-pb-5 gl-border-b-1 gl-border-b-solid gl-border-b-gray-100"
    >
      <div class="gl-mr-5">
        <span>{{ $options.i18n.helpText }}</span>
        <gl-link class="gl-ml-2" :href="$options.GEO_INFO_URL" target="_blank">{{
          $options.i18n.learnMore
        }}</gl-link>
      </div>
      <gl-button
        v-if="!noNodes"
        class="gl-w-full gl-md-w-auto gl-ml-auto gl-mr-5 gl-mt-5 gl-md-mt-0"
        variant="confirm"
        :href="newNodeUrl"
        target="_blank"
        >{{ $options.i18n.addSite }}
      </gl-button>
    </div>
    <gl-loading-icon v-if="isLoading" size="xl" class="gl-mt-5" />
    <div v-if="!isLoading">
      <geo-nodes v-for="node in nodes" :key="node.id" :node="node" />
      <geo-nodes-empty-state v-if="noNodes" :svg-path="geoNodesEmptyStateSvg" />
    </div>
  </section>
</template>
