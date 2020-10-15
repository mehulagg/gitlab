<script>
import { GlLink } from '@gitlab/ui';
import { __ } from '~/locale';

export default {
  components: {
    GlLink,
  },
  props: {
    imagePath: {
      type: String,
      required: true,
    },
  },
  strings: {
    heading: __('Includes completed merge requests.'),
    subheading: __("You haven't yet finished a merge request."),
    documentation: __('View documentation'),
    alt: __('Merge Requests'),
  },
  documentationPath:
    'https://docs.gitlab.com/ee/user/compliance/compliance_dashboard/index.html#overview',
};
</script>

<template>
  <div class="empty-state gl-display-flex gl-flex-direction-column">
    <div class="gl-mx-5">
      <div class="svg-content">
        <img :src="imagePath" :alt="$options.strings.alt" />
      </div>
    </div>
    <div class="gl-mx-5">
      <div class="text-content gl-text-center">
        <h4>{{ $options.strings.heading }}</h4>
        <p>{{ $options.strings.subheading }}</p>
        <gl-link :href="$options.documentationPath">{{ $options.strings.documentation }}</gl-link>
      </div>
    </div>
  </div>
</template>
