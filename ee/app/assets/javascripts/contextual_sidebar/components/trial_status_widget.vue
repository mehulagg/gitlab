<script>
import { GlLink, GlProgressBar } from '@gitlab/ui';
import { n__, sprintf } from '~/locale';

export default {
  tracking: {
    event: 'click_link',
    label: 'trial_status_widget',
    property: 'experiment:show_trial_status_in_sidebar',
  },
  components: {
    GlLink,
    GlProgressBar,
  },
  props: {
    containerId: {
      type: [String, null],
      required: false,
      default: null,
    },
    daysRemaining: {
      type: Number,
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
    planName: {
      type: String,
      required: true,
    },
    plansHref: {
      type: String,
      required: true,
    },
  },
  computed: {
    widgetTitle() {
      const i18nWidgetTitle = n__(
        'Trials|%{planName} Trial %{enDash} %{num} day left',
        'Trials|%{planName} Trial %{enDash} %{num} days left',
        this.daysRemaining,
      );

      return sprintf(i18nWidgetTitle, {
        planName: this.planName,
        enDash: '–',
        num: this.daysRemaining,
      });
    },
  },
};
</script>

<template>
  <gl-link
    :id="containerId"
    :title="widgetTitle"
    :href="plansHref"
    :data-track-event="$options.tracking.event"
    :data-track-label="$options.tracking.label"
    :data-track-property="$options.tracking.property"
  >
    <div class="gl-display-flex gl-flex-direction-column gl-align-items-stretch gl-w-full">
      <span class="gl-display-flex gl-align-items-center">
        <span class="nav-icon-container svg-container">
          <img :src="navIconImagePath" width="16" class="svg" />
        </span>
        <span class="nav-item-name gl-white-space-normal">
          {{ widgetTitle }}
        </span>
      </span>
      <span class="gl-display-flex gl-align-items-stretch gl-mt-3">
        <gl-progress-bar :value="percentageComplete" class="gl-flex-grow-1" />
      </span>
    </div>
  </gl-link>
</template>
