<script>
import { GlTab, GlTabs } from '@gitlab/ui';
import { __, s__ } from '~/locale';
import FeatureCard from './feature_card.vue';

export default {
  components: {
    GlTab,
    GlTabs,
    FeatureCard,
  },
  props: {
    securityFeatures: {
      type: Array,
      required: true,
    },
    complianceFeatures: {
      type: Array,
      required: true,
    },
  },
  i18n: {
    compliance: s__('SecurityConfiguration|Compliance'),
    securityTesting: s__('SecurityConfiguration|Security testing'),

    // TODO: Need different description for non-Ultimate, as statuses won't be available
    // FIXME: Add link around "latest pipeline"
    securityTestingDescription: s__(
      `SecurityConfiguration|The status of the tools only applies to the
      default branch and is based on the latest pipeline. Once you've enabled a
      scan for the default branch, any subsequent feature branch you create
      will include the scan.`,
    ),
    securityConfiguration: __('Security Configuration'),
  },
};
</script>

<template>
  <article>
    <header>
      <!-- TODO: h1? -->
      <h4 class="gl-my-5">{{ $options.i18n.securityConfiguration }}</h4>
    </header>

    <!-- TODO: Add upgrade banner CTA - show if any features are unavailable?
    -->

    <!-- TODO: extract layout component? -->
    <gl-tabs content-class="gl-pt-6">
      <gl-tab :title="$options.i18n.securityTesting">
        <div class="row">
          <div class="col-lg-5">
            <h4 class="gl-mt-0">{{ $options.i18n.securityTesting }}</h4>
            <p class="gl-line-height-20">{{ $options.i18n.securityTestingDescription }}</p>
            <!-- TODO: add Configuration history link. This will require Ruby
              work to move the gitlab_ci_present to FOSS -->
          </div>
          <div class="col-lg-7">
            <feature-card
              v-for="feature in securityFeatures"
              :key="feature.type"
              :feature="feature"
              class="gl-mb-6"
            />
          </div>
        </div>
      </gl-tab>
      <gl-tab :title="$options.i18n.compliance">
        <div class="row">
          <div class="col-lg-5">
            <h4 class="gl-mt-0">{{ $options.i18n.compliance }}</h4>
          </div>
          <div class="col-lg-7">
            <feature-card
              v-for="feature in complianceFeatures"
              :key="feature.type"
              :feature="feature"
              class="gl-mb-6"
            />
          </div>
        </div>
      </gl-tab>
    </gl-tabs>
  </article>
</template>
