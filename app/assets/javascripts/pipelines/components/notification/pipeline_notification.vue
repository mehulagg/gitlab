<script>
import { GlBanner, GlLink, GlSprintf } from '@gitlab/ui';
import { __ } from '~/locale';

export default {
  i18n: {
    title: __('Order jobs based on job dependencies!'),
    description: __(
      'You can now group jobs in the pipeline graph based on which jobs are configured to run first, if you use the %{codeStart}needs:%{codeEnd} keyword to establish job dependencies in your CI/CD pipelines. %{linkStart}Learn how to speed up your pipeline with needs.%{linkEnd}',
    ),
    buttonText: __('Provide feedback'),
  },
  components: {
    GlBanner,
    GlLink,
    GlSprintf,
  },
  inject: ['dagDocPath'],
  methods: {
    handleClose() {},
  },
};
</script>
<template>
  <gl-banner
    :title="$options.i18n.title"
    :button-text="$options.i18n.buttonText"
    :button-link="dagDocPath"
    variant="introduction"
    @close="handleClose"
  >
    <p>
      <gl-sprintf :message="$options.i18n.description">
        <template #link="{ content }">
          <gl-link :href="dagDocPath"> {{ content }}</gl-link>
        </template>
        <template #code="{ content }">
          <code>{{ content }}</code>
        </template>
      </gl-sprintf>
    </p>
  </gl-banner>
</template>
