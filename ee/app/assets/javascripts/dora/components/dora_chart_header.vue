<script>
import { GlLink, GlSprintf } from '@gitlab/ui';
import { environmentTierDocumentationHref } from './static_data/shared';

export default {
  name: 'DoraChartHeader',
  components: {
    GlLink,
    GlSprintf,
  },
  props: {
    headerText: {
      type: String,
      required: true,
    },
    chartDescriptionText: {
      type: String,
      required: true,
    },
    chartDocumentationHref: {
      type: String,
      required: true,
    },
  },
  environmentTierDocumentationHref,
};
</script>
<template>
  <div>
    <h4 class="gl-my-4">{{ headerText }}</h4>
    <p data-testid="help-text">
      <gl-sprintf :message="chartDescriptionText">
        <template #link="{ content }">
          <gl-link :href="$options.environmentTierDocumentationHref" target="_blank"
            ><code>{{ content }}</code></gl-link
          >
        </template>
      </gl-sprintf>
      <gl-link :href="chartDocumentationHref" target="_blank">
        {{ __('Learn more.') }}
      </gl-link>
    </p>
  </div>
</template>
