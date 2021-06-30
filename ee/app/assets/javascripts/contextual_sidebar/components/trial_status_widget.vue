<script>
import { GlLink, GlProgressBar } from '@gitlab/ui';
import { sprintf } from '~/locale';
import Tracking from '~/tracking';
import { TRACKING_PROPERTY, WIDGET } from './constants';

const { i18n, trackingEvents } = WIDGET;
const trackingMixin = Tracking.mixin({ property: TRACKING_PROPERTY });

export default {
  components: {
    GlLink,
    GlProgressBar,
  },
  mixins: [trackingMixin],
  inject: {
    containerId: { default: null },
    daysRemaining: {},
    navIconImagePath: {},
    percentageComplete: {},
    planName: {},
    plansHref: {},
  },
  i18n,
  trackingEvents,
  computed: {
    widgetTitle() {
      const i18nWidgetTitle = this.$options.i18n.widgetTitle.countableTranslator(
        this.daysRemaining,
      );

      return sprintf(i18nWidgetTitle, {
        planName: this.planName,
        enDash: '–',
        num: this.daysRemaining,
      });
    },
  },
  methods: {
    onWidgetClick() {
      const { action, ...options } = this.$options.trackingEvents.widgetClick;
      this.track(action, options);
    },
  },
};
</script>

<template>
  <gl-link :id="containerId" :title="widgetTitle" :href="plansHref" @click="onWidgetClick">
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
