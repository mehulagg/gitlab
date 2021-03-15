<script>
import { GlBadge, GlTooltipDirective } from '@gitlab/ui';
import { scrollToElement, historyPushState } from '~/lib/utils/common_utils';
import { stripFinalUrlSegment } from '~/lib/utils/url_utility';
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
  methods: {
    onClick() {
      // switch to the MR "Overview" tab and scroll to the codequality widget
      window.mrTabs.eventHub.$once('MergeRequestTabChange', () => {
        setTimeout(() => scrollToElement('.js-codequality-widget'), 0);
      });
      window.mrTabs.tabShown('show');

      // update browser location/history to reflect the tab change
      const newUrl = stripFinalUrlSegment(window.location.href);
      historyPushState(newUrl);
    },
  },
  i18n: {
    badgeTitle: __('Code Quality'),
    badgeTooltip: __(
      'The merge request has been updated, and the number of code quality violations in this file has changed.',
    ),
  },
};
</script>

<template>
  <span @click="onClick">
    <gl-badge v-gl-tooltip :title="$options.i18n.badgeTooltip" icon="information">
      {{ $options.i18n.badgeTitle }}
    </gl-badge>
  </span>
</template>
