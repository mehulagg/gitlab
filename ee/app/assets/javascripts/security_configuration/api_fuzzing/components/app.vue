<script>
import { GlAlert, GlLink, GlLoadingIcon, GlSprintf } from '@gitlab/ui';
import { s__ } from '~/locale';
import apiFuzzingCiConfigurationQuery from '../graphql/api_fuzzing_ci_configuration.query.graphql';
import ConfigurationForm from './configuration_form.vue';

export default {
  components: {
    GlAlert,
    GlLink,
    GlLoadingIcon,
    GlSprintf,
    ConfigurationForm,
  },
  inject: {
    fullPath: {
      from: 'fullPath',
    },
    apiFuzzingDocumentationPath: {
      from: 'apiFuzzingDocumentationPath',
    },
  },
  apollo: {
    apiFuzzingCiConfiguration: {
      query: apiFuzzingCiConfigurationQuery,
      variables() {
        return {
          fullPath: this.fullPath,
        };
      },
      update({ project: { apiFuzzingCiConfiguration } }) {
        return apiFuzzingCiConfiguration;
      },
    },
  },
  i18n: {
    title: s__('APIFuzzing|API Fuzzing Configuration'),
    helpText: s__(`
      APIFuzzing|Customize common API fuzzing settings to suit your requirements.
      For details of more advanced configuration options, see the
      %{docsLinkStart}GitLab API Fuzzing documentation%{docsLinkEnd}.`),
    notice: s__(`
      APIFuzzing|Use this tool to generate API fuzzing configuration YAML to copy into your
      .gitlab-ci.yml file. This tool does not reflect or update your .gitlab-ci.yml file automatically.
    `),
  },
};
</script>

<template>
  <article>
    <header class="gl-mt-5 gl-border-b-1 gl-border-b-gray-100 gl-border-b-solid">
      <h4>
        {{ s__('APIFuzzing|API Fuzzing Configuration') }}
      </h4>
      <p>
        <gl-sprintf :message="$options.i18n.helpText">
          <template #docsLink="{ content }">
            <gl-link :href="apiFuzzingDocumentationPath" target="_blank">{{ content }}</gl-link>
          </template>
        </gl-sprintf>
      </p>
    </header>

    <gl-alert :dismissible="false" class="gl-mb-5">
      {{ $options.i18n.notice }}
    </gl-alert>

    <gl-loading-icon v-if="$apollo.loading" size="lg" />

    <configuration-form v-else :api-fuzzing-ci-configuration="apiFuzzingCiConfiguration" />
  </article>
</template>
