<script>
import { GlLink, GlSprintf } from '@gitlab/ui';
import { s__ } from '~/locale';

export default {
  components: {
    GlLink,
    GlSprintf,
  },
  inject: {
    dastDocumentationPath: {
      from: 'dastDocumentationPath',
    },
    gitlabCiYamlEditPath: {
      from: 'gitlabCiYamlEditPath',
    },
  },
  i18n: {
    helpText: s__(`
      DastConfig|Configure DAST to automatically test your project's running application for vulnerabilities in your CI pipeline. Configuration changes must be added to your gitlab-ci.yaml file to be enabled. For details about more advanced configuration options, see the  %{docsLinkStart}GitLab DAST documentation%{docsLinkEnd}.`),
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
    {{ gitlabCiYamlEditPath }}
  </section>
</template>
