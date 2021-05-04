<script>
import { GlCard, GlLink, GlSprintf } from '@gitlab/ui';
import { s__ } from '~/locale';
import JobPill from '~/pipelines/components/pipeline_graph/job_pill.vue';

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
      'PipelineEditorTutorial|Commit and run this pipeline, then navigate to the %{linkStart}Pipeline Page%{linkEnd} to track the pipeline status.',
    ),
    note: s__(
      'PipelineEditorTutorial|Note: If you’re using self-hosted GitLab instance, %{linkStart}make sure you have Runners available.%{linkEnd}',
    ),
  },
  components: {
    GlCard,
    GlLink,
    GlSprintf,
    JobPill,
  },
};
</script>
<template>
  <gl-card>
    <template #default>
      <h4 class="gl-font-lg gl-mt-0">{{ $options.i18n.title }}</h4>
      <p class="gl-mb-3">{{ $options.i18n.firstParagraph }}</p>
      <p class="gl-mb-3">{{ $options.i18n.secondParagraph }}</p>
      <div class="gl-display-flex">
        <div class="gl-bg-blue-50 gl-mr-3">
          <div>Build</div>
          <job-pill job-name="build" :pipeline-id="0" />
        </div>
        <div class="gl-bg-blue-50 gl-mr-3">
          <div>Test</div>
          <job-pill job-name="test" :pipeline-id="0" />
        </div>
        <div class="gl-bg-blue-50 gl-mr-3">
          <div>Deploy</div>
          <job-pill job-name="deploy" :pipeline-id="0" />
        </div>
      </div>
      <p class="gl-mb-3">
        <gl-sprintf :message="$options.i18n.thirdParagraph">
          <template #link="{ content }">
            <gl-link href="#">{{ content }}</gl-link>
          </template>
        </gl-sprintf>
      </p>
      <p class="gl-mb-0">
        <gl-sprintf :message="$options.i18n.note">
          <template #link="{ content }">
            <gl-link href="#">{{ content }}</gl-link>
          </template>
        </gl-sprintf>
      </p>
    </template>
  </gl-card>
</template>
