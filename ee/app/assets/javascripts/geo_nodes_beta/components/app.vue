<script>
import { GlSprintf, GlLink, GlButton } from '@gitlab/ui';
import { __ } from '~/locale';
import GeoNodes from './geo_nodes.vue';

export default {
  name: 'GeoNodesBetaApp',
  components: {
    GlSprintf,
    GlLink,
    GlButton,
    GeoNodes,
  },
  props: {
    geoInformationPath: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      nodes: [
        {
          id: 1,
          primary: true,
          current: true,
          name: __('Team primary'),
          // eslint-disable-next-line @gitlab/require-i18n-strings
          status: 'Healthy',
          statusCheckTimestamp: 1612213132611,
        },
        {
          id: 2,
          primary: false,
          current: false,
          name: __('Team secondary'),
          // eslint-disable-next-line @gitlab/require-i18n-strings
          status: 'Unhealthy',
          statusCheckTimestamp: 1612013102611,
        },
      ],
    };
  },
};
</script>

<template>
  <section>
    <h3>{{ __('Geo sites') }}</h3>
    <div
      class="gl-display-flex gl-align-items-center gl-border-b-1 gl-border-b-solid gl-border-b-gray-100 gl-pb-4"
    >
      <gl-sprintf
        :message="
          s__(
            'Geo|With GitLab Geo, you can install a special read-only and replicated instance anywhere. %{linkStart}More Information%{linkEnd}',
          )
        "
      >
        <template #link="{ content }">
          <gl-link class="gl-ml-2" :href="geoInformationPath" target="_blank">{{
            content
          }}</gl-link>
        </template>
      </gl-sprintf>
      <gl-button class="gl-ml-auto" variant="success">{{ __('New site') }}</gl-button>
    </div>
    <geo-nodes v-for="node in nodes" :key="node.id" :node="node" />
  </section>
</template>
