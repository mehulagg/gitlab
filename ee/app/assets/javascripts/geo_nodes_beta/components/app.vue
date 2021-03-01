<script>
import { GlLink, GlButton } from '@gitlab/ui';
import { mapActions, mapState } from 'vuex';
import { GEO_INFO_URL } from '../constants';
import GeoNodes from './geo_nodes.vue';

export default {
  name: 'GeoNodesBetaApp',
  components: {
    GlLink,
    GlButton,
    GeoNodes,
  },
  props: {
    newNodeUrl: {
      type: String,
      required: true,
    },
  },
  computed: {
    ...mapState(['nodes']),
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
    <h3>{{ s__('Geo|Geo sites') }}</h3>
    <div
      class="gl-display-flex gl-flex-direction-column gl-md-flex-direction-row gl-md-align-items-center gl-pb-5 gl-border-b-1 gl-border-b-solid gl-border-b-gray-100"
    >
      <div class="gl-mr-5">
        <span>{{
          s__(
            'Geo|With GitLab Geo, you can install a special read-only and replicated instance anywhere.',
          )
        }}</span>
        <gl-link class="gl-ml-2" :href="$options.GEO_INFO_URL" target="_blank">{{
          __('Learn more')
        }}</gl-link>
      </div>
      <gl-button
        class="gl-w-full gl-md-w-auto gl-ml-auto gl-mr-5 gl-mt-5 gl-md-mt-0"
        variant="confirm"
        :href="newNodeUrl"
        target="_blank"
        >{{ s__('Geo|Add site') }}
      </gl-button>
    </div>
    <geo-nodes v-for="node in nodes" :key="node.id" :node="node" />
  </section>
</template>
