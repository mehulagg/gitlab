<script>
import { GlLink, GlSprintf, GlButton, GlForm } from '@gitlab/ui';
import ConfigurationSnippetModal from 'ee/security_configuration/components/configuration_snippet_modal.vue';
import { CONFIGURATION_SNIPPET_MODAL_ID } from 'ee/security_configuration/components/constants';
import { s__ } from '~/locale';

export default {
  components: {
    GlLink,
    GlSprintf,
    GlButton,
    GlForm,
  },
  inject: {
    dastDocumentationPath: {
      from: 'dastDocumentationPath',
    },
  },
  i18n: {
    helpText: s__(`
      DastConfig|Customize DAST settings to suit your requirements. Configuration changes made here override these provided by GitLab and are excluded from updates. For details of more advanced configuration options, see the %{docsLinkStart}GitLab DAST documentation%{docsLinkEnd}.`),
  },
  data() {
    return {
      selectedSiteProfileId: '1',
      selectedScannerProfileId: '2',
    };
  },
  methods: {
    onsubmit() {
      // this.generateSnippet();
    },
  },
};
</script>

<template>
  <section class="gl-mt-5">
    <p>
      <gl-sprintf :message="$options.i18n.helpText">
        <template #docsLink="{ content }">
          <gl-link :href="dastDocumentationPath" target="_blank">{{ content }}</gl-link>
        </template>
      </gl-sprintf>
    </p>

    <gl-form @submit.prevent="onSubmit">
      <!-- DAST Scanner Profile -->
      {{ selectedScannerProfileId }}
      <br />
      <!-- DAST Site Profile -->
      {{ selectedSiteProfileId }}

      <hr />

      <gl-button
        :disabled="someFieldEmpty"
        :loading="isLoading"
        type="submit"
        variant="confirm"
        class="js-no-auto-disable"
        data-testid="api-fuzzing-configuration-submit-button"
        >{{ s__('APIFuzzing|Generate code snippet') }}</gl-button
      >
      <gl-button
        :disabled="isLoading"
        :href="securityConfigurationPath"
        data-testid="api-fuzzing-configuration-cancel-button"
        >{{ __('Cancel') }}</gl-button
      >

      <configuration-snippet-modal
        :ref="$options.CONFIGURATION_SNIPPET_MODAL_ID"
        :ci-yaml-edit-url="ciYamlEditPath"
        :yaml="configurationYamlWithTips"
        :redirect-param="$options.CODE_SNIPPET_SOURCE_API_FUZZING"
        scan-type="DAST"
      />
    </gl-form>
  </section>
</template>
