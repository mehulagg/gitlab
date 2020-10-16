<script>
import { isEmpty } from 'lodash';
import { GlAlert } from '@gitlab/ui';
import { __ } from '~/locale';
import JobPill from './job_pill.vue';
import SfGraph from './sf_graph.vue';
import StagePill from './stage_pill.vue';

import { DRAW_FAILURE, DEFAULT } from '../../constants';
import SfGraphLinks from './sf_graph_links.vue';

export default {
  components: {
    GlAlert,
    JobPill,
    SfGraph,
    SfGraphLinks,
    StagePill,
  },
  CONTAINER_REF: 'PIPELINE_GRAPH_CONTAINER_REF',
  CONTAINER_ID: 'pipeline-graph-container',
  STROKE_WIDTH: 2,
  errorTexts: {
    [DRAW_FAILURE]: __('Could not draw the lines for job relationships'),
    [DEFAULT]: __('An unknown error occurred.'),
  },
  props: {
    pipelineData: {
      required: true,
      type: Object,
    },
  },
  data() {
    return {
      failureType: null,
      highlightedJob: null,
      highlightedJobs: [],
    };
  },
  computed: {
    isPipelineDataEmpty() {
      return isEmpty(this.pipelineData);
    },
    hasError() {
      return this.failureType;
    },
    hasHighlightedJob() {
      return Boolean(this.highlightedJob);
    },
    failure() {
      const text = this.$options.errorTexts[this.failureType] || this.$options.errorTexts[DEFAULT];

      return { text, variant: 'danger' };
    },
  },
  methods: {
    highlightNeeds(uniqueJobId) {
      this.highlightedJob = uniqueJobId;
    },
    removeHighlightNeeds() {
      this.highlightedJob = '';
    },
    reportFailure(errorType) {
      this.failureType = errorType;
    },
    resetFailure() {
      this.failureType = null;
    },
    setHighlightedJobs(highlightedJobs) {
      this.highlightedJobs = highlightedJobs;
    },
    isJobHighlighted(jobName) {
      return this.highlightedJobs.includes(jobName);
    },
  },
};
</script>
<template>
  <div>
    <gl-alert v-if="hasError" :variant="failure.variant" @dismiss="resetFailure">
      {{ failure.text }}
    </gl-alert>
    <gl-alert v-if="isPipelineDataEmpty" variant="tip" :dismissible="false">
      {{ __('No content to show') }}
    </gl-alert>
    <div
      v-else
      :id="$options.CONTAINER_ID"
      :ref="$options.CONTAINER_REF"
      class="gl-display-flex gl-bg-gray-50 gl-px-4 gl-overflow-auto gl-relative gl-py-7"
    >
      <sf-graph-links
        :pipeline-data="pipelineData"
        :highlighted-job="highlightedJob"
        :container-id="$options.CONTAINER_ID"
        :container-ref="$options.CONTAINER_REF"
        @on-highlighted-jobs-change="setHighlightedJobs"
      >
        <template :default="highlightedJobs">
          <div v-for="(stage, index) in pipelineData.stages" :key="`${stage.name}-${index}`">
            <sf-graph stage-classes="" job-classes="" :stage="stage">
              <template #stages>
                <stage-pill :stage-name="stage.name" :is-empty="stage.groups.length === 0" />
              </template>
              <template #jobs>
                <job-pill
                  v-for="group in stage.groups"
                  :key="group.name"
                  :job-id="group.id"
                  :job-name="group.name"
                  :is-highlighted="hasHighlightedJob && isJobHighlighted(group.id)"
                  :is-faded-out="hasHighlightedJob && !isJobHighlighted(group.id)"
                  @on-mouse-enter="highlightNeeds"
                  @on-mouse-leave="removeHighlightNeeds"
                />
              </template>
            </sf-graph>
          </div>
        </template>
      </sf-graph-links>
    </div>
  </div>
</template>
