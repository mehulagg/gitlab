<script>
import { GlCard, GlLink, GlSprintf } from '@gitlab/ui';
import { s__ } from '~/locale';
import PipelineVisualReference from '../ui/pipeline_visual_reference.vue';

export default {
  i18n: {
    title: s__('PipelineEditorTutorial|🚀 Run your first pipeline'),
    firstParagraph: s__(
      'PipelineEditorTutorial|A typical GitLab pipeline will consist of a Build, Test and Deploy stages with multiple jobs in each stage.',
    ),
    secondParagraph: s__(
      'PipelineEditorTutorial|In the example below, each stage contains one job with simple execution scripts.',
    ),
    thirdParagraph: s__(
      'PipelineEditorTutorial|Use %{linkStart}CI/CD examples and templates%{linkEnd} to get started with your configuration, then commit the %{codeStart}.gitlab-ci.yml%{codeEnd} to run your first pipeline.',
    ),
    note: s__(
      'PipelineEditorTutorial|Note: If you’re using self-hosted GitLab instance, %{linkStart}make sure you have Runners available.%{linkEnd}',
    ),
  },
  components: {
    GlCard,
    GlLink,
    GlSprintf,
    PipelineVisualReference,
  },
  inject: ['ciExamplesHelpPagePath', 'runnerHelpPagePath'],
};
</script>
<template>
  <gl-card>
    <template #default>
      <h4 class="gl-font-lg gl-mt-0">{{ $options.i18n.title }}</h4>
      <p class="gl-mb-3">{{ $options.i18n.firstParagraph }}</p>
      <p class="gl-mb-3">{{ $options.i18n.secondParagraph }}</p>
      <pipeline-visual-reference />
      <p class="gl-my-3">
        <gl-sprintf :message="$options.i18n.thirdParagraph">
          <template #link="{ content }">
            <gl-link :href="ciExamplesHelpPagePath" target="_blank" data-testid="pipelines-link">
              {{ content }}
            </gl-link>
          </template>
          <template #code="{ content }">
            <code>{{ content }}</code>
          </template>
        </gl-sprintf>
      </p>
      <p class="gl-mb-0">
        <gl-sprintf :message="$options.i18n.note">
          <template #link="{ content }">
            <gl-link :href="runnerHelpPagePath" target="_blank" data-testid="runners-link">
              {{ content }}
            </gl-link>
          </template>
        </gl-sprintf>
      </p>
    </template>
  </gl-card>
</template>
