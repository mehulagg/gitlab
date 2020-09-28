<script>
import * as d3 from 'd3';
import { isEmpty } from 'lodash';
import { GlAlert } from '@gitlab/ui';
import JobPill from './job_pill.vue';
import StagePill from './stage_pill.vue';
import { parseData } from '../parsing_utils';
import { drawGraphLinks } from './drawing_utils';

export default {
  components: {
    GlAlert,
    JobPill,
    StagePill,
  },
  CONTAINER_REF: 'PIPELINE_GRAPH_CONTAINER_REF',
  props: {
    pipelineData: {
      required: true,
      type: Object,
    },
  },
  data() {
    return {
      height: 0,
      width: 0,
    };
  },
  computed: {
    isPipelineDataEmpty() {
      return isEmpty(this.pipelineData);
    },
    emptyClass() {
      return !this.isPipelineDataEmpty ? 'gl-py-7' : '';
    },
  },
  mounted() {
    this.width = `${this.$refs[this.$options.CONTAINER_REF].scrollWidth}px`;
    this.height = `${this.$refs[this.$options.CONTAINER_REF].scrollHeight}px`;

    const svg = this.addSvg();

    const unwrappedGroups = this.pipelineData.stages
      .map(({ name, groups }) => {
        return groups.map(group => {
          return { category: name, ...group };
        });
      })
      .flat(2);

    drawGraphLinks(parseData(unwrappedGroups), svg);
  },
  methods: {
    addSvg() {
      return d3
        .select('#pipeline-graph-container')
        .append('svg')
        .attr('style', 'position: absolute;')
        .attr('viewBox', [0, 0, this.width, this.height])
        .attr('width', this.width)
        .attr('height', this.height);
    },
  },
};
</script>
<template>
  <div
    id="pipeline-graph-container"
    :ref="$options.CONTAINER_REF"
    class="gl-display-flex gl-bg-gray-50 gl-px-4 gl-overflow-auto gl-relative"
    :class="emptyClass"
  >
    <gl-alert v-if="isPipelineDataEmpty" variant="tip" :dismissible="false">
      {{ __('No content to show') }}
    </gl-alert>
    <template v-else>
      <div
        v-for="(stage, index) in pipelineData.stages"
        :key="`${stage.name}-${index}`"
        class="gl-flex-direction-column"
      >
        <div
          class="gl-display-flex gl-align-items-center gl-bg-white gl-w-full gl-px-8 gl-py-4 gl-mb-5"
          :class="{
            'stage-left-rounded': index === 0,
            'stage-right-rounded': index === pipelineData.stages.length - 1,
          }"
        >
          <stage-pill :stage-name="stage.name" :is-empty="stage.groups.length === 0" />
        </div>
        <div
          class="gl-display-flex gl-flex-direction-column gl-align-items-center gl-w-full gl-px-8"
        >
          <job-pill v-for="group in stage.groups" :key="group.name" :job-name="group.name" />
        </div>
      </div>
    </template>
  </div>
</template>
