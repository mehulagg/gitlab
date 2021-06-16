<script>
import { GlPopover, GlSprintf, GlLink } from '@gitlab/ui';
import { __ } from '~/locale';
import UserCalloutDismisser from '~/vue_shared/components/user_callout_dismisser.vue';
import TopNavApp from './top_nav_app.vue';

const MESSAGE = __(
  'Your projects, groups, and dashboards are now in a simpler, combined menu. We welcome your comments in this %{linkStart}feedback issue%{linkEnd}.',
);
const FEEDBACK_URL = 'https://gitlab.com/gitlab-org/gitlab/-/issues/332635';

export default {
  components: {
    GlPopover,
    GlSprintf,
    GlLink,
    UserCalloutDismisser,
    TopNavApp,
  },
  inheritAttrs: false,
  props: {
    navData: {
      type: Object,
      required: true,
    },
  },
  methods: {
    getToggleElement() {
      return this.$el?.querySelector('.js-top-nav-dropdown-toggle');
    },
    safeDismiss({ dismiss, isDismissed }) {
      if (!isDismissed) {
        dismiss();
      }
    },
  },
  MESSAGE,
  FEEDBACK_URL,
};
</script>

<template>
  <user-callout-dismisser feature-name="combined_menu_top_nav">
    <template #default="{ shouldShowCallout, ...calloutProps }">
      <top-nav-app :nav-data="navData" @shown="safeDismiss(calloutProps)">
        <gl-popover
          v-if="shouldShowCallout"
          :target="getToggleElement"
          triggers="manual"
          placement="bottomright"
          show
        >
          <div data-testid="popover-content" @click="safeDismiss(calloutProps)">
            <gl-sprintf :message="$options.MESSAGE">
              <template #link="{ content }">
                <gl-link class="gl-font-sm!" :href="$options.FEEDBACK_URL">{{ content }}</gl-link>
              </template>
            </gl-sprintf>
          </div>
        </gl-popover>
      </top-nav-app>
    </template>
  </user-callout-dismisser>
</template>
