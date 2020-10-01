<script>
import { GlButton, GlTabs, GlTab } from '@gitlab/ui';
import AlertsSettingsForm from './alerts_form.vue';
import PagerDutySettingsForm from './pagerduty_form.vue';
import ServiceLevelAgreementForm from './service_level_agreement_form.vue';
import { INTEGRATION_TABS_CONFIG, I18N_INTEGRATION_TABS } from '../constants';
import { s__ } from '~/locale';

export default {
  components: {
    GlButton,
    GlTabs,
    GlTab,
    AlertsSettingsForm,
    PagerDutySettingsForm,
    ServiceLevelAgreementForm,
  },
  i18n: I18N_INTEGRATION_TABS,
  inject: ['serviceLevelAgreementSettings'],
  computed: {
    tabs() {
      return [
        ...INTEGRATION_TABS_CONFIG,
        {
          title: s__('IncidentSettings|Incident Settings'),
          component: 'ServiceLevelAgreementForm',
          active: this.serviceLevelAgreementSettings.available,
        },
      ];
    },
  },
};
</script>

<template>
  <section
    id="incident-management-settings"
    data-qa-selector="incidents_settings_content"
    class="settings no-animate qa-incident-management-settings"
  >
    <div class="settings-header">
      <h4 ref="sectionHeader" class="gl-my-3! gl-py-1">
        {{ $options.i18n.headerText }}
      </h4>
      <gl-button ref="toggleBtn" class="js-settings-toggle">{{
        $options.i18n.expandBtnLabel
      }}</gl-button>
      <p ref="sectionSubHeader">
        {{ $options.i18n.subHeaderText }}
      </p>
    </div>

    <div class="settings-content">
      <gl-tabs>
        <gl-tab
          v-for="(tab, index) in tabs"
          v-if="tab.active"
          :key="`${tab.title}_${index}`"
          :title="tab.title"
        >
          <component :is="tab.component" class="gl-pt-3" :data-testid="`${tab.component}-tab`" />
        </gl-tab>
      </gl-tabs>
    </div>
  </section>
</template>
