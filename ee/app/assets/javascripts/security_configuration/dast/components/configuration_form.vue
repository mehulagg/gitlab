<script>
import { GlLink, GlSprintf } from '@gitlab/ui';
import { s__ } from '~/locale';
import { DAST_HELP_PATH } from '~/security_configuration/components/constants';

export default {
  components: {
    GlLink,
    GlSprintf,
  },
  i18n: {
    helpText: s__(`
      DastConfig|Customize DAST settings to suit your requirements. Configuration changes made here override those provided by GitLab and are excluded from updates. For details of more advanced configuration options, see the %{docsLinkStart}GitLab DAST documentation%{docsLinkEnd}.`),
  },
  DAST_HELP_PATH,
};
</script>

<template>
  <section class="gl-mt-5">
    <p>
      <gl-sprintf :message="$options.i18n.helpText">
        <template #docsLink="{ content }">
          <gl-link :href="$options.DAST_HELP_PATH" target="_blank">{{ content }}</gl-link>
        </template>
      </gl-sprintf>
    </p>
  </section>
</template>
