<script>
import { GlLink, GlSprintf } from '@gitlab/ui';
import { s__ } from '~/locale';

export default {
  name: 'MergeTrainHelperText',
  components: {
    GlLink,
    GlSprintf,
  },
  props: {
    pipelineId: {
      type: Number,
      required: true,
    },
    pipelineLink: {
      type: String,
      required: true,
    },
    mergeTrainWhenPipelineSucceedsDocsPath: {
      type: String,
      required: true,
    },
    mergeTrainLength: {
      type: Number,
      required: true,
    },
  },
  computed: {
    helperMessage() {
      return this.mergeTrainLength === 0
        ? s__(
            'mrWidget|This action will start a merge train when pipeline %{pipelineLink} succeeds.',
          )
        : s__(
            'mrWidget|This action will add the merge request to the merge train when pipeline %{pipelineLink} succeeds.',
          );
    },
  },
};
</script>

<template>
  <section class="js-merge-train-helper-text gl-px-5 gl-pb-5">
    <div class="gl-pl-7">
      <gl-sprintf :message="helperMessage">
        <template #pipelineLink>
          <gl-link data-testid="pipeline-link" :href="pipelineLink">#{{ pipelineId }}</gl-link>
        </template>
      </gl-sprintf>
      <gl-link
        :href="mergeTrainWhenPipelineSucceedsDocsPath"
        target="_blank"
        rel="noopener noreferrer"
        data-testid="documentation-link"
      >
        {{ s__('mrWidget|More information') }}
      </gl-link>
    </div>
  </section>
</template>
