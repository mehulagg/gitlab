<script>
import _ from 'lodash-es';
import { GlLink } from '@gitlab/ui';
import { s__, sprintf } from '~/locale';

export default {
  name: 'MergeTrainHelperText',
  components: {
    GlLink,
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
    message() {
      const text =
        this.mergeTrainLength === 0
          ? s__(
              'mrWidget|This merge request will start a merge train when pipeline %{linkStart}#%{pipelineId}%{linkEnd} succeeds.',
            )
          : s__(
              'mrWidget|This merge request will be added to the merge train when pipeline %{linkStart}#%{pipelineId}%{linkEnd} succeeds.',
            );

      const sanitizedPipelineLink = _.escape(this.pipelineLink);

      return sprintf(
        text,
        {
          pipelineId: this.pipelineId,
          linkStart: `<a class="js-pipeline-link" href="${sanitizedPipelineLink}">`,
          linkEnd: '</a>',
        },
        false,
      );
    },
  },
};
</script>

<template>
  <section class="js-merge-train-helper-text mr-widget-help border-top">
    <span v-html="message"></span>
    <gl-link
      :href="mergeTrainWhenPipelineSucceedsDocsPath"
      target="_blank"
      rel="noopener noreferrer"
      class="js-documentation-link"
    >
      {{ s__('mrWidget|More information') }}
    </gl-link>
  </section>
</template>
