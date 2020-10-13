<script>
import { mapGetters } from 'vuex';
import { GlEmptyState } from '@gitlab/ui';

export default {
  name: 'GeoReplicableEmptyState',
  components: {
    GlEmptyState,
  },
  props: {
    geoReplicableEmptySvgPath: {
      type: String,
      required: true,
    },
    geoTroubleshootingLink: {
      type: String,
      required: true,
    },
  },
  computed: {
    ...mapGetters(['replicableTypeName']),
  },
};
</script>

<template>
  <gl-empty-state
    :title="sprintf(__('There are no %{replicableTypeName} to show'), { replicableTypeName })"
    :svg-path="geoReplicableEmptySvgPath"
  >
    <template #description>
      <p>
        <gl-sprintf
          :message="
            s__(
              'Geo|Adjust your filters/search criteria above. If you believe this may be an error, please refer to the %{linkStart}Geo Troubleshooting%{linkEnd} documentation for more information.',
            )
          "
        >
          <template #link="{ content }">
            <gl-link :href="geoTroubleshootingLink" target="_blank">{{ content }}</gl-link>
          </template>
        </gl-sprintf>
      </p>
    </template>
  </gl-empty-state>
</template>
