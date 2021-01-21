<script>
import { GlEmptyState, GlLink, GlSprintf } from '@gitlab/ui';
import { EMPTY_STATE_DESCRIPTION, NO_ENVIRONMENT_TITLE } from './constants';

export default {
  i18n: { EMPTY_STATE_DESCRIPTION, NO_ENVIRONMENT_TITLE },
  name: 'NoEnvironmentEmptyState',
  components: {
    GlEmptyState,
    GlLink,
    GlSprintf,
  },
  inject: {
    documentationPath: { type: String, default: '' },
    emptyStateSvgPath: { type: String, default: '' },
  },
};
</script>

<template>
  <gl-empty-state :title="$options.i18n.NO_ENVIRONMENT_TITLE" :svg-path="emptyStateSvgPath">
    <template #description>
      <gl-sprintf :message="$options.i18n.EMPTY_STATE_DESCRIPTION">
        <template #link="{ content }">
          <gl-link :href="documentationPath" target="_blank">{{ content }}</gl-link>
        </template>
      </gl-sprintf>
    </template>
  </gl-empty-state>
</template>
