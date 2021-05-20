<script>
import { GlLink, GlSprintf, GlTab, GlTabs } from '@gitlab/ui';
import { __, s__ } from '~/locale';
import FeatureCard from './feature_card.vue';
import SectionLayout from './section_layout.vue';
import UpgradeBanner from './upgrade_banner.vue';
import DismissibleUserCallout from '~/vue_shared/components/dismissible_user_callout.vue';

export default {
  name: 'SecurityConfigurationApp',
  components: {
    DismissibleUserCallout,
    GlLink,
    GlSprintf,
    GlTab,
    GlTabs,
    FeatureCard,
    SectionLayout,
    UpgradeBanner,
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
    showUpgradeBanner() {
      return [...this.securityFeatures, ...this.complianceFeatures].some(
        ({ available }) => !available,
      );
    },
  },
  i18n: {
    compliance: s__('SecurityConfiguration|Compliance'),
    configurationHistory: s__('SecurityConfiguration|Configuration history'),
    securityConfiguration: __('Security Configuration'),
    securityTesting: s__('SecurityConfiguration|Security testing'),
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

    <dismissible-user-callout
      v-if="showUpgradeBanner"
      feature-name="security_configuration_upgrade_banner"
    >
      <template #default="{ dismiss }">
        <upgrade-banner @close="dismiss" />
      </template>
    </dismissible-user-callout>

    <gl-tabs content-class="gl-pt-6">
      <gl-tab :title="$options.i18n.securityTesting">
        <section-layout :heading="$options.i18n.securityTesting">
          <p v-if="latestPipelinePath" class="gl-line-height-20">
            <gl-sprintf :message="$options.i18n.securityTestingDescription">
              <template #link="{ content }">
                <gl-link :href="latestPipelinePath">{{ content }}</gl-link>
              </template>
            </gl-sprintf>
          </p>
          <p v-if="canViewCiHistory">
            <gl-link :href="gitlabCiHistoryPath">{{ $options.i18n.configurationHistory }}</gl-link>
          </p>

          <template #features>
            <feature-card
              v-for="feature in securityFeatures"
              :key="feature.type"
              :feature="feature"
              class="gl-mb-6"
            />
          </template>
        </section-layout>
      </gl-tab>
      <gl-tab :title="$options.i18n.compliance">
        <section-layout :heading="$options.i18n.compliance">
          <template #features>
            <feature-card
              v-for="feature in complianceFeatures"
              :key="feature.type"
              :feature="feature"
              class="gl-mb-6"
            />
          </template>
        </section-layout>
      </gl-tab>
    </gl-tabs>
  </article>
</template>
