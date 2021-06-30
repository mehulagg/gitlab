<script>
import { GlAlert, GlLink, GlSprintf } from '@gitlab/ui';
import { s__ } from '~/locale';

export default {
  components: {
    GlSprintf,
    GlAlert,
    GlLink,
  },
  inject: ['autoDevopsDocsPath', 'enableAutoDevopsPath'],
  i18n: {
    primaryButtonText: s__('AutoDevopsAlert|Enable Auto DevOps'),
    body: s__(
      'AutoDevopsAlert|Quickly enable all continuous testing and compliance tools by enabling %{linkStart}Auto DevOps%{linkEnd}',
    ),
  },
};
</script>

<template>
  <gl-alert
    variant="info"
    :primary-button-link="enableAutoDevopsPath"
    :primary-button-text="$options.i18n.primaryButtonText"
    @dismiss="$emit('dismiss')"
  >
    <gl-sprintf :message="$options.i18n.body">
      <template #link="{ content }">
        <gl-link data-testid="auto-devops-alert-link" :href="autoDevopsDocsPath">
          {{ content }}
        </gl-link>
      </template>
    </gl-sprintf>
  </gl-alert>
</template>
