<script>
import { mapGetters } from 'vuex';
import { GlEmptyState } from '@gitlab/ui';
import { s__, sprintf } from '~/locale';

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
    linkText() {
      return sprintf(
        s__(
          'Geo|Adjust your filters/search criteria above. If you believe this may be an error, please refer to the %{linkStart}Geo Troubleshooting%{linkEnd} documentation for more information.',
        ),
        {
          linkStart: `<a href="${this.geoTroubleshootingLink}" target="_blank">`,
          linkEnd: '</a>',
        },
        false,
      );
    },
  },

  emits: [],
};
</script>

<template>
  <gl-empty-state
    :title="sprintf(__('There are no %{replicableTypeName} to show'), { replicableTypeName })"
    :svg-path="geoReplicableEmptySvgPath"
  >
    <template #description>
      <div>
        <p v-html="linkText"></p>
      </div>
    </template>
  </gl-empty-state>
</template>
