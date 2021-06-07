<script>
import { GlCard, GlLink, GlSprintf } from '@gitlab/ui';
import { s__ } from '~/locale';
import PipelineVisualReference from '../ui/pipeline_visual_reference.vue';

export default {
  i18n: {
    title: s__('PipelineEditorTutorial|🚀 Run your first pipeline'),
    firstParagraph: s__(
      'PipelineEditorTutorial|This template creates a simple test pipeline. To use it:',
    ),
    listItems: s__(
      `PipelineEditorTutorial|
        %{listItemStart}Commit the file to your repository. The pipeline then runs automatically.%{listItemEnd}
        %{listItemStart}The pipeline status is at the top of the page.%{listItemEnd}
        %{listItemStart}Select the pipeline ID to view the full details about your first pipeline run.%{listItemEnd}
      `
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
      <ol class="gl-mb-3">
        <gl-sprintf :message="$options.i18n.listItems">
            <template #listItem="{ content }">
              <li>{{ content }}</li>
            </template>
        </gl-sprintf>
      </ol>
    </template>
  </gl-card>
</template>
