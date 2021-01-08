<script>
import { GlLink, GlSprintf, GlAlert } from '@gitlab/ui';
import { mapState } from 'vuex';

export default {
  components: {
    GlLink,
    GlSprintf,
    GlAlert,
  },
  computed: {
    ...mapState(['ancestorHelperPath', 'hasAncestorClusters']),
  },
};
</script>

<template>
  <gl-alert v-if="hasAncestorClusters" variant="info" :dismissible="false" class="gl-mt-3">
    <p>
      <gl-sprintf
        :message="
          s__(
            'ClusterIntegration|Clusters are utilized by selecting the nearest ancestor with a matching environment scope. For example, project clusters will override group clusters. %{linkStart}More information%{linkEnd}',
          )
        "
      >
        <template #link="{ content }">
          <gl-link :href="ancestorHelperPath">
            <strong>{{ content }}</strong>
          </gl-link>
        </template>
      </gl-sprintf>
    </p>
  </gl-alert>
</template>
