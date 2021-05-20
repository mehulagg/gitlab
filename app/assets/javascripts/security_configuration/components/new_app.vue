<script>
import { GlLink, GlSprintf, GlTab, GlTabs } from '@gitlab/ui';
import { __, s__ } from '~/locale';
import FeatureCard from './feature_card.vue';

export default {
  name: 'SecurityConfigurationApp',
  components: {
    GlLink,
    GlSprintf,
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
    gitlabCiPresent: {
      type: Boolean,
      required: false,
      default: false,
    },
    gitlabCiHistoryPath: {
      type: String,
      required: false,
      default: '',
    },
    latestPipelinePath: {
      type: String,
      required: false,
      default: '',
    },
  },
  computed: {
    canViewCiHistory() {
      return Boolean(this.gitlabCiPresent && this.gitlabCiHistoryPath);
    },
  },
  i18n: {
    compliance: s__('SecurityConfiguration|Compliance'),
    configurationHistory: s__('SecurityConfiguration|Configuration history'),
    securityConfiguration: __('Security Configuration'),
    securityTesting: s__('SecurityConfiguration|Security testing'),

    // TODO: Need different description for non-Ultimate, as statuses won't be available
    // FIXME: Add link around "latest pipeline"
    securityTestingDescription: s__(
      `SecurityConfiguration|The status of the tools only applies to the
      default branch and is based on the %{linkStart}latest pipeline%{linkEnd}.
      Once you've enabled a scan for the default branch, any subsequent feature
      branch you create will include the scan.`,
    ),
  },
};
</script>

<template>
  <article>
    <header>
      <h1 class="gl-font-size-h1">{{ $options.i18n.securityConfiguration }}</h1>
    </header>

    <!-- TODO: Add upgrade banner CTA - show if any features are unavailable?
    -->

    <!-- TODO: extract layout component? -->
    <gl-tabs content-class="gl-pt-6">
      <gl-tab :title="$options.i18n.securityTesting">
        <div class="row">
          <div class="col-lg-5">
            <h2 class="gl-font-size-h2 gl-mt-0">{{ $options.i18n.securityTesting }}</h2>
            <p v-if="latestPipelinePath" class="gl-line-height-20">
              <gl-sprintf :message="$options.i18n.securityTestingDescription">
                <template #link="{ content }">
                  <gl-link :href="latestPipelinePath">{{ content }}</gl-link>
                </template>
              </gl-sprintf>
            </p>
            <p v-if="canViewCiHistory">
              <gl-link :href="gitlabCiHistoryPath">{{
                $options.i18n.configurationHistory
              }}</gl-link>
            </p>
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
            <h2 class="gl-font-size-h2 gl-mt-0">{{ $options.i18n.compliance }}</h2>
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
