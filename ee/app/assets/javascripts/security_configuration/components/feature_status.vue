<script>
import { GlLink } from '@gitlab/ui';

export default {
  components: {
    GlLink,
  },
  props: {
    feature: {
      type: Object,
      required: true,
    },
    gitlabCiPresent: {
      type: Boolean,
      required: false,
      default: false,
    },
    gitlabCiHistoryPath: {
      type: String,
      required: false,
      default: '',
    },
  },
  computed: {
    canViewCiHistory() {
      const { type, configured } = this.feature;
      return type === 'sast' && configured && this.gitlabCiPresent;
    },
  },
};
</script>

<template>
  <div>
    {{ feature.status }}
    <template v-if="canViewCiHistory">
      <br />
      <gl-link :href="gitlabCiHistoryPath">{{ s__('SecurityConfiguration|View history') }}</gl-link>
    </template>
  </div>
</template>
