<script>
import {
  GlButton,
  GlTooltipDirective,
  GlCarousel,
  GlCarouselSlide,
  GlSprintf,
  GlLink,
} from '@gitlab/ui';
import securityDependencyImageUrl from 'ee_images/promotions/security-dependencies.png';
import securityScanningImageUrl from 'ee_images/promotions/security-scanning.png';
import securityDashboardImageUrl from 'ee_images/promotions/security-dashboard.png';
import Tracking from '~/tracking';
import { s__ } from '~/locale';

export default {
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  components: {
    GlButton,
    GlCarousel,
    GlCarouselSlide,
    GlSprintf,
    GlLink,
  },
  mixins: [Tracking.mixin()],
  props: {
    project: {
      type: Object,
      required: false,
      default: null,
    },
    group: {
      type: Object,
      required: false,
      default: null,
    },
    linkMain: {
      type: String,
      required: false,
      default: '',
    },
    linkSecondary: {
      type: String,
      required: false,
      default: '',
    },
    linkFeedback: {
      type: String,
      required: false,
      default: '',
    },
  },
  data: () => ({
    slide: 0,
    textSlide: 0,
    carouselImages: [
      {
        index: 0,
        imageUrl: securityDependencyImageUrl,
      },
      {
        index: 1,
        imageUrl: securityScanningImageUrl,
      },
      {
        index: 2,
        imageUrl: securityDashboardImageUrl,
      },
    ],
  }),
  computed: {
    discoverButtonProps() {
      return {
        variant: 'info',
        // False positive i18n lint: https://gitlab.com/gitlab-org/frontend/eslint-plugin-i18n/issues/26
        // eslint-disable-next-line @gitlab/require-i18n-strings
        rel: 'noopener noreferrer',
        class: 'discover-button justify-content-center',
        'data-track-event': 'click_button',
      };
    },
  },
  methods: {
    onSlideStart(slide) {
      this.track('click_button', {
        label: 'security-discover-carousel',
        property: `sliding${this.slide}-${slide}`,
      });
      this.textSlide = slide;
    },
  },
  i18n: {
    discoverTitle: s__(
      'Discover|Security capabilities, integrated into your development lifecycle',
    ),
    discoverFeedbackLabel: s__('Discover|Give feedback for this page'),
    discoverUpgradeLabel: s__('Discover|Upgrade now'),
    discoverTrialLabel: s__('Discover|Start a free trial'),
    carouselCaptions: [
      {
        index: 0,
        caption: s__(
          'Discover|Check your application for security vulnerabilities that may lead to unauthorized access, data leaks, and denial of services.',
        ),
      },
      {
        index: 1,
        caption: s__(
          'Discover|GitLab will perform static and dynamic tests on the code of your application, looking for known flaws and report them in the merge request so you can fix them before merging.',
        ),
      },
      {
        index: 2,
        caption: s__(
          "Discover|For code that's already live in production, our dashboards give you an easy way to prioritize any issues that are found, empowering your team to ship quickly and securely.",
        ),
      },
    ],
    discoverPlanCaption: s__(
      'Discover|See the other features of the %{linkStart}gold plan%{linkEnd}',
    ),
  },
};
</script>

<template>
  <div class="discover-box">
    <h4 class="discover-title center gl-text-gray-900">
      {{ $options.i18n.discoverTitle }}
    </h4>
    <gl-carousel
      v-model="slide"
      class="discover-carousel"
      :no-wrap="true"
      controls
      :interval="0"
      indicators
      img-width="1440"
      img-height="700"
      @sliding-start="onSlideStart"
    >
      <gl-carousel-slide v-for="{ index, imageUrl } in carouselImages" :key="index" img-blank>
        <img
          :src="imageUrl"
          class="discover-carousel-img w-100 box-shadow-default image-fluid d-block"
        />
      </gl-carousel-slide>
    </gl-carousel>
    <gl-carousel
      ref="textCarousel"
      v-model="textSlide"
      class="discover-carousel discover-text-carousel"
      :no-wrap="true"
      :interval="0"
      img-width="1440"
      img-height="200"
    >
      <gl-carousel-slide
        v-for="{ index, caption } in $options.i18n.carouselCaptions"
        :key="index"
        img-blank
      >
        <p class="gl-text-gray-900 gl-text-left">
          {{ caption }}
        </p>
      </gl-carousel-slide>
    </gl-carousel>
    <div class="discover-footer d-flex flex-nowrap flex-row justify-content-between mx-auto my-0">
      <p class="gl-text-gray-900 text-left mb-5">
        <gl-sprintf :message="$options.i18n.discoverPlanCaption">
          <template #link="{ content }">
            <gl-link
              href="https://about.gitlab.com/pricing/saas/feature-comparison/"
              target="_blank"
            >
              {{ content }}
            </gl-link>
          </template>
        </gl-sprintf>
      </p>
    </div>
    <div class="discover-buttons d-flex flex-nowrap flex-row justify-content-between mx-auto my-0">
      <gl-button
        class="discover-button-upgrade"
        v-bind="discoverButtonProps"
        category="secondary"
        data-track-label="security-discover-upgrade-cta"
        :data-track-property="slide"
        :href="linkSecondary"
      >
        {{ $options.i18n.discoverUpgradeLabel }}
      </gl-button>
      <gl-button
        class="discover-button-trial"
        v-bind="discoverButtonProps"
        category="primary"
        data-track-label="security-discover-trial-cta"
        :data-track-property="slide"
        :href="linkMain"
      >
        {{ $options.i18n.discoverTrialLabel }}
      </gl-button>
    </div>
    <div id="tooltipcontainer" class="discover-feedback w-30p position-fixed">
      <gl-button
        v-gl-tooltip:tooltipcontainer.left
        :title="$options.i18n.discoverFeedbackLabel"
        icon="slight-smile"
        size="medium"
        class="discover-feedback-icon"
        category="secondary"
        variant="default"
        target="_blank"
        rel="noopener noreferrer"
        data-track-event="click_button"
        data-track-label="security-discover-feedback-cta"
        :data-track-property="slide"
        :href="linkFeedback"
      />
    </div>
  </div>
</template>
