<script>
import { GlLink, GlProgressBar } from '@gitlab/ui';

export default {
  components: {
    GlLink,
    GlProgressBar,
  },
  props: {
    href: {
      type: String,
      required: true,
    },
    navIconImagePath: {
      type: String,
      required: true,
    },
    percentageComplete: {
      type: Number,
      required: true,
    },
    title: {
      type: String,
      required: true,
    },
  },
};
</script>

<template>
  <gl-link :title="title" :href="href">
    <div class="gl-display-flex gl-flex-direction-column gl-align-items-stretch gl-w-full">
      <span class="gl-display-flex gl-align-items-center">
        <span class="nav-icon-container svg-container">
          <img :src="navIconImagePath" width="16" class="svg" />
        </span>
        <span class="nav-item-name gl-white-space-normal">
          {{ title }}
        </span>
      </span>
      <span class="gl-display-flex gl-align-items-stretch gl-mt-3">
        <gl-progress-bar :value="percentageComplete" class="gl-flex-grow-1" />
      </span>
    </div>
  </gl-link>
</template>
