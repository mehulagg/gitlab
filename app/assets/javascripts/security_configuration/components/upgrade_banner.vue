<script>
import { GlBanner } from '@gitlab/ui';
import { s__ } from '~/locale';

export default {
  components: {
    GlBanner,
  },
  inject: ['upgradePath'],
  i18n: {
    title: s__('SecurityConfiguration|Secure your project with Ultimate'),
    body: s__(
      'SecurityConfiguration|GitLab Ultimate can check your application for security vulnerabilities that may lead to unauthorized access, data leaks, and denial of services.',
    ),
    buttonText: s__('SecurityConfiguration|Start a free trial'),
  },
};
</script>

<template>
  <gl-banner
    :title="$options.i18n.title"
    :button-text="$options.i18n.buttonText"
    :button-link="upgradePath"
    v-on="$listeners"
  >
    <p>{{ $options.i18n.body }}</p>
  </gl-banner>
</template>
