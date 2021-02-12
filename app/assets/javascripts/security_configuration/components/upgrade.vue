<script>
import { GlLink, GlSprintf } from '@gitlab/ui';
import { UPGRADE_CTA } from './features_constants';

export default {
  components: {
    GlLink,
    GlSprintf,
  },
  i18n: {
    UPGRADE_CTA,
  },
  methods: {
    getLink: () => {
      // if (window.gon?.dot_com) {
      //   return DISCOVER_SECURITY_HREF;
      // } else {
      //   return PRICING_HREF;
      // }
      // They're viewing a project in a group/namespace they are an admin of
      // They're on any plan except Ultimate
    },
  },
};
</script>

<template>
  <span>
    <gl-sprintf :message="$options.i18n.UPGRADE_CTA">
      <template #link="{ content }">
        <gl-link target="_blank" :href="getLink()">
          {{ content }}
        </gl-link>
      </template>
    </gl-sprintf>
  </span>
</template>
