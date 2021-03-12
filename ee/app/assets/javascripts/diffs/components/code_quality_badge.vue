<script>
import { GlBadge, GlTooltipDirective } from '@gitlab/ui';
import { __ } from '~/locale';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';

export default {
  components: {
    GlBadge,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  mixins: [glFeatureFlagsMixin()],
  i18n: {
    badgeTitle: __('Code Quality'),
    badgeTooltip: __(
      'The merge request has been updated, and the number of code quality violations in this file has changed.',
    ),
  },
};
</script>

<template>
  <gl-badge v-gl-tooltip :title="$options.i18n.badgeTooltip" icon="information">
    {{ $options.i18n.badgeTitle }}
  </gl-badge>
</template>
