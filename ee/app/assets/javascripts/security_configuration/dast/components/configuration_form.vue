<script>
import { GlLink, GlSprintf, GlButton, GlForm } from '@gitlab/ui';
import ConfigurationSnippetModal from 'ee/security_configuration/components/configuration_snippet_modal.vue';
import { CONFIGURATION_SNIPPET_MODAL_ID } from 'ee/security_configuration/components/constants';
import { s__ } from '~/locale';
import { CODE_SNIPPET_SOURCE_DAST } from '~/pipeline_editor/components/code_snippet_alert/constants';
import { DAST_HELP_PATH } from '~/security_configuration/components/constants';
import { DAST_YML_CONFIGURATION_TEMPLATE } from '../constants';

export default {
  DAST_HELP_PATH,
  CONFIGURATION_SNIPPET_MODAL_ID,
  CODE_SNIPPET_SOURCE_DAST,
  components: {
    GlLink,
    GlSprintf,
    GlButton,
    GlForm,
    ConfigurationSnippetModal,
  },
  inject: ['gitlabCiYamlEditPath', 'securityConfigurationPath'],
  i18n: {
    helpText: s__(`
      DastConfig|Customize DAST settings to suit your requirements. Configuration changes made here override those provided by GitLab and are excluded from updates. For details of more advanced configuration options, see the %{docsLinkStart}GitLab DAST documentation%{docsLinkEnd}.`),
  },
  computed: {
    configurationYaml() {
      return DAST_YML_CONFIGURATION_TEMPLATE.replace(
        '#DAST_SITE_PROFILE_NAME',
        this.selectedSiteProfileName,
      ).replace('#DAST_SCANNER_PROFILE_NAME', this.selectedScannerProfileName);
    },
  },
  methods: {
    onSubmit() {
      this.$refs[CONFIGURATION_SNIPPET_MODAL_ID].show();
    },
  },
};
</script>

<template>
  <gl-form @submit.prevent="onSubmit">
    <section class="gl-mt-5">
      <p>
        <gl-sprintf :message="$options.i18n.helpText">
          <template #docsLink="{ content }">
            <gl-link :href="$options.DAST_HELP_PATH" target="_blank">{{ content }}</gl-link>
          </template>
        </gl-sprintf>
      </p>
    </section>

    <scanner-profile-selector
      v-model="selectedScannerProfileId"
      class="gl-mb-5"
      :profiles="scannerProfiles"
      :selected-profile="selectedScannerProfile"
      :has-conflict="hasProfilesConflict"
    />
    <site-profile-selector
      v-model="selectedSiteProfileId"
      class="gl-mb-5"
      :profiles="siteProfiles"
      :selected-profile="selectedSiteProfile"
      :has-conflict="hasProfilesConflict"
    />

    <gl-button
      :disabled="someFieldEmpty"
      :loading="isLoading"
      type="submit"
      variant="confirm"
      class="js-no-auto-disable"
      data-testid="dast-configuration-submit-button"
      >{{ s__('APIFuzzing|Generate code snippet') }}</gl-button
    >
    <gl-button
      :disabled="isLoading"
      :href="securityConfigurationPath"
      data-testid="dast-configuration-cancel-button"
      >{{ __('Cancel') }}</gl-button
    >

    <configuration-snippet-modal
      :ref="$options.CONFIGURATION_SNIPPET_MODAL_ID"
      :ci-yaml-edit-url="gitlabCiYamlEditPath"
      :yaml="configurationYaml"
      :redirect-param="$options.CODE_SNIPPET_SOURCE_DAST"
      scan-type="DAST"
    />
  </gl-form>
</template>
