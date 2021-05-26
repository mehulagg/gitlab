<script>
import { GlAlert, GlLink, GlSprintf } from '@gitlab/ui';
import { __ } from '~/locale';

export default {
  i18n: {
    title: __('No more scheduled pipelines can run today.'),
    description: __(
      'Projects in the GitLab free tier can only have a maximum of 10 active pipeline schedules per day. %{linkStart}Learn More%{linkEnd}',
    ),
  },
  inject: {
    docsUrl: {
      default: '',
    },
  },
  components: {
    GlAlert,
    GlLink,
    GlSprintf,
  },
};
</script>

<template>
  <gl-alert class="gl-my-3" variant="warning" :title="$options.i18n.title" :dismissible="false">
    <gl-sprintf :message="$options.i18n.description">
      <template #link="{ content }">
        <gl-link class="gl-text-decoration-none" :href="docsUrl" target="_blank">
          {{ content }}
        </gl-link>
      </template>
    </gl-sprintf>
  </gl-alert>
</template>
