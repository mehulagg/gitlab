<script>
import { GlButton, GlLink, GlPopover, GlProgressBar } from '@gitlab/ui';

export default {
  components: {
    GlButton,
    GlLink,
    GlPopover,
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
  <div>
    <gl-link :title="title" :href="href" id="trial-status-sidebar-widget">
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

    <gl-popover
      target="trial-status-sidebar-widget"
      triggers="hover"
      placement="rightbottom"
      boundary="viewport"
      :delay="{ hide: 400 }"
    >
      <template #title>Hey there 👋</template>

      Your trial ends on <b>YYYY-MM-DD</b>. We hope you are enjoying GitLab Gold. To continue using
      GitLab Gold after your trial ends, you will need to buy a subscription. You can also choose
      Silver or Bronze if their features meet your needs.

      <div class="gl-mt-5">
        <gl-button
          href="#in-app-purchase-flow"
          category="primary"
          variant="confirm"
          size="small"
          class="gl-mb-0"
          block
          title="Upgrade {group_name} to Gold"
        >
          <span class="gl-font-sm">Upgrade {group_name} to Gold</span>
        </gl-button>
        <gl-button
          href="#billing-page"
          category="secondary"
          variant="confirm"
          size="small"
          class="gl-mb-0"
          block
          title="Compare all plans"
        >
          <span class="gl-font-sm">Compare all plans</span>
        </gl-button>
      </div>
    </gl-popover>
  </div>
</template>
