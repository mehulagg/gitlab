<script>
import { GlLink, GlLoadingIcon, GlSprintf } from '@gitlab/ui';
import { s__ } from '~/locale';
import ConfigurationForm from './configuration_form.vue';
import apiFuzzingCiConfigurationQuery from '../graphql/api_fuzzing_ci_configuration.query.graphql';

export default {
  components: {
    GlLink,
    GlLoadingIcon,
    GlSprintf,
    ConfigurationForm,
  },
  inject: {
    fullPath: {
      from: 'fullPath',
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
    title: s__('SecurityConfiguration|API Fuzzing Configuration'),
    helpText: s__(`
      SecurityConfiguration|Customize common API fuzzing settings to suit your requirements.
      For details of more advanced configuration options, see the
      %{docsLinkStart}GitLab API Fuzzing documentation%{docsLinkEnd}.`),
  },
};
</script>

<template>
  <article>
    <header class="gl-my-5 gl-border-b-1 gl-border-b-gray-100 gl-border-b-solid">
      <h2 class="h4">
        {{ s__('SecurityConfiguration|API Fuzzing Configuration') }}
      </h2>
      <p>
        <gl-sprintf :message="$options.i18n.helpText">
          <template #docsLink="{ content }">
            <gl-link href="#" target="_blank" v-text="content" />
          </template>
        </gl-sprintf>
      </p>
    </header>

    <gl-loading-icon v-if="$apollo.loading" size="lg" />

    <template v-else>
      <configuration-form :api-fuzzing-ci-configuration="apiFuzzingCiConfiguration" />
    </template>
  </article>
</template>
