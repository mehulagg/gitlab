<script>
import { GlCard, GlIcon, GlPopover, GlLink } from '@gitlab/ui';
import { mapGetters } from 'vuex';
import { HELP_INFO_URL } from 'ee/geo_nodes_beta/constants';
import { sprintf, s__ } from '~/locale';
import GeoNodeProgressBar from '../geo_node_progress_bar.vue';

export default {
  name: 'GeoNodeVerificationInfo',
  components: {
    GlCard,
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
  computed: {
    ...mapGetters(['verificationInfo']),
    verificationInfoBars() {
      return this.verificationInfo(this.node.id);
    },
  },
  methods: {
    buildTitle(title) {
      return sprintf(s__('Geo|%{title} checksum progress'), { title });
    },
  },
  HELP_INFO_URL,
};
</script>

<template>
  <gl-card header-class="gl-display-flex gl-align-items-center">
    <template #header>
      <h5 class="gl-my-0">{{ s__('Geo|Verificaton information') }}</h5>
      <gl-icon
        ref="verificationInfo"
        tabindex="0"
        name="question"
        class="gl-text-blue-500 gl-cursor-pointer gl-ml-2"
      />
      <gl-popover :target="() => $refs.verificationInfo.$el" placement="top" triggers="hover focus">
        <p>
          {{ s__('Geo|Replicated data is verified with the secondary node(s) using checksums') }}
        </p>
        <gl-link :href="$options.HELP_INFO_URL" target="_blank">{{ __('Learn more') }}</gl-link>
      </gl-popover>
    </template>
    <div v-for="bar in verificationInfoBars" :key="bar.title" class="gl-mb-5">
      <span data-testid="verificationBarTitle">{{ buildTitle(bar.title) }}</span>
      <geo-node-progress-bar
        class="gl-mt-3"
        :title="`${bar.title} checksum`"
        :values="bar.values"
      />
    </div>
  </gl-card>
</template>
