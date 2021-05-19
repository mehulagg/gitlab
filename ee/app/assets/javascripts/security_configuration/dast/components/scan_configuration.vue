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
  },
  i18n: {
    title: s__('DastConfig|Scan Configuration'),
    helpText: s__(`
      DastConfig|Customize DAST settings to suit your requirements. Configuration changes made here override these provided by GitLab and are excluded from updates. For details of more advanced configuration options, see the %{docsLinkStart}GitLab DAST documentation%{docsLinkEnd}.`),
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
  </section>
</template>
