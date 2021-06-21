<script>
import { GlIcon, GlProgressBar } from '@gitlab/ui';
import { sprintf } from '~/locale';
import { DEVOPS_ADOPTION_FEATURES_ADOPTED_TEXT } from '../constants';

export default {
  name: 'DevopsAdoptionOverviewCard',
  components: {
    GlIcon,
    GlProgressBar,
  },
  props: {
    icon: {
      type: String,
      required: true,
    },
    title: {
      type: String,
      required: true,
    },
    adoptedCount: {
      type: Number,
      required: false,
      default: 1,
    },
    featuresCount: {
      type: Number,
      required: false,
      default: 3,
    },
    variant: {
      type: String,
      required: false,
      default: 'primary',
    },
    featureMeta: {
      type: Object,
      required: false,
      default: () => ({}),
    },
  },
  computed: {
    description() {
      return sprintf(DEVOPS_ADOPTION_FEATURES_ADOPTED_TEXT, {
        adoptedCount: this.adoptedCount,
        featuresCount: this.featuresCount,
      });
    },
  },
};
</script>
<template>
  <div class="gl-display-flex gl-flex-direction-column gl-w-quarter">
    <div class="gl-display-flex gl-align-items-center gl-mb-2">
      <gl-icon :name="icon" class="gl-mr-3" />
      <span class="gl-font-md gl-font-weight-bold">{{ title }}</span>
    </div>
    <gl-progress-bar :value="adoptedCount" :max="featuresCount" class="gl-mb-2" />
    <div class="gl-text-gray-400">{{ description }}</div>
  </div>
</template>
