<script>
import { GlTab, GlTabs, GlSprintf } from '@gitlab/ui';
import { __, s__ } from '~/locale';
import FeatureCard from './feature_card.vue';

export default {
  components: {
    GlTab,
    GlTabs,
    GlSprintf,
    FeatureCard,
  },
  props: {
    augmentedSecurityFeatures: {
      type: Array,
      required: true,
    },
  },
  i18n: {
    compliance: s__('SecurityConfiguration|Compliance'),
    securityTesting: s__('SecurityConfiguration|Security testing'),

    // TODO: Need different description for non-Ultimate, as statuses won't be available

    securityTestingDescription: s__(
      `SecurityConfiguration|The status of the tools only applies to the
      default branch and is based on the %{link}. Once you've enabled a
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
      <!-- TODO styling like that ok? -->
      <h1 class="h4">{{ $options.i18n.securityConfiguration }}</h1>
    </header>

    <gl-tabs content-class="gl-pt-6">
      <gl-tab data-testid="security-testing-tab" :title="$options.i18n.securityTesting">
        <div class="row">
          <div class="col-lg-5">
            <h4 class="gl-mt-0">{{ $options.i18n.securityTesting }}</h4>
            <p>
              <gl-sprintf :message="$options.i18n.securityTestingDescription">
                <template #link>
                  <a href="TODOLINKTOLATESTPIPELINE">{{ __('latest pipeline') }}</a>
                </template>
              </gl-sprintf>
            </p>
          </div>
          <div class="col-lg-7">
            <feature-card
              v-for="feature in augmentedSecurityFeatures"
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
