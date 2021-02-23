<script>
import { GlSprintf } from '@gitlab/ui';
import { s__ } from '~/locale';

export default {
  components: {
    GlSprintf,
  },
  i18n: {
    title: s__('PipelineEditor|Optimize your workflow with CI/CD Pipelines'),
    body: s__(
      'PipelineEditor|Create a new %{codeStart}.gitlab-ci.yml%{codeEnd} file at the root of the repository to get started.',
    ),
  },
  inject: {
    emptyStateIllustrationPath: {
      default: '',
    },
  },
};
</script>
<template>
  <div class="gl-display-flex gl-flex-direction-column gl-align-items-center">
    <img :src="emptyStateIllustrationPath" data-testid="empty-state-illustration" />
    <h1 class="gl-font-size-h1">{{ $options.i18n.title }}</h1>
    <p>
      <gl-sprintf :message="$options.i18n.body" class="gl-display-inline">
        <template #code="{ content }">
          <code>{{ content }}</code>
        </template>
      </gl-sprintf>
    </p>
  </div>
</template>
