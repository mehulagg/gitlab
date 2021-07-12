<script>
import * as d3 from 'd3';
import { GlDropdown, GlDropdownItem } from '@gitlab/ui';
import { createJobsHash, generateJobNeedsDict, reportToSentry } from '../../utils';
import LinkedGraphWrapper from '../graph_shared/linked_graph_wrapper.vue';
import LinksLayer from '../graph_shared/links_layer.vue';
import { generateColumnsFromLayersListMemoized } from '../parsing_utils';
import { DOWNSTREAM, MAIN, UPSTREAM, ONE_COL_WIDTH, STAGE_VIEW } from './constants';
import LinkedPipelinesColumn from './linked_pipelines_column.vue';
import StageColumnComponent from './stage_column_component.vue';
import { validateConfigPaths } from './utils';
import JobGroupDropdown from './job_group_dropdown.vue';
import JobItem from './job_item.vue';

export default {
  name: 'PipelineGraph',
  components: {
    GlDropdown,
    GlDropdownItem,
    JobGroupDropdown,
    JobItem,
    LinksLayer,
    LinkedGraphWrapper,
    LinkedPipelinesColumn,
    StageColumnComponent,
  },
  props: {
    configPaths: {
      type: Object,
      required: true,
      validator: validateConfigPaths,
    },
    pipeline: {
      type: Object,
      required: true,
    },
    showLinks: {
      type: Boolean,
      required: true,
    },
    viewType: {
      type: String,
      required: true,
    },
    isLinkedPipeline: {
      type: Boolean,
      required: false,
      default: false,
    },
    pipelineLayers: {
      type: Array,
      required: false,
      default: () => [],
    },
    type: {
      type: String,
      required: false,
      default: MAIN,
    },
  },
  gitLabColorRotation: [
    '#e17223',
    '#83ab4a',
    '#5772ff',
    '#b24800',
    '#25d2d2',
    '#006887',
    '#487900',
    '#d84280',
    '#3547de',
    '#6f3500',
    '#006887',
    '#275600',
    '#b31756',
  ],
  pipelineTypeConstants: {
    DOWNSTREAM,
    UPSTREAM,
  },
  CONTAINER_REF: 'PIPELINE_LINKS_CONTAINER_REF',
  BASE_CONTAINER_ID: 'pipeline-links-container',
  data() {
    return {
      color: () => {},
      hoveredJobName: '',
      hoveredSourceJobName: '',
      highlightedJobs: [],
      measurements: {
        width: 0,
        height: 0,
      },
      pipelineExpanded: {
        jobName: '',
        expanded: false,
      },
      needsObject: {},
      selectedJob: '',
    };
  },
  computed: {
    allGroups() {
      return this.layout.flatMap(({ groups }) => groups);
    },
    allGroupNames() {
      return this.allGroups.map(({ name }) => name);
    },
    containerId() {
      return `${this.$options.BASE_CONTAINER_ID}-${this.pipeline.id}`;
    },
    downstreamPipelines() {
      return this.hasDownstreamPipelines ? this.pipeline.downstream : [];
    },
    layout() {
      return this.isStageView
        ? this.pipeline.stages
        : generateColumnsFromLayersListMemoized(this.pipeline, this.pipelineLayers);
    },
    hasDownstreamPipelines() {
      return Boolean(this.pipeline?.downstream?.length > 0);
    },
    hasUpstreamPipelines() {
      return Boolean(this.pipeline?.upstream?.length > 0);
    },
    isStageView() {
      return this.viewType === STAGE_VIEW;
    },
    metricsConfig() {
      return {
        path: this.configPaths.metricsPath,
        collectMetrics: true,
      };
    },
    showJobLinks() {
      return !this.isStageView && this.showLinks;
    },
    // The show downstream check prevents showing redundant linked columns
    showDownstreamPipelines() {
      return (
        this.hasDownstreamPipelines && this.type !== this.$options.pipelineTypeConstants.UPSTREAM
      );
    },
    // The show upstream check prevents showing redundant linked columns
    showUpstreamPipelines() {
      return (
        this.hasUpstreamPipelines && this.type !== this.$options.pipelineTypeConstants.DOWNSTREAM
      );
    },
    upstreamPipelines() {
      return this.hasUpstreamPipelines ? this.pipeline.upstream : [];
    },
    dropdownText() {
      return this.selectedJob || 'Select Job to See Dependency List';
    },
  },
  errorCaptured(err, _vm, info) {
    reportToSentry(this.$options.name, `error: ${err}, info: ${info}`);
  },
  mounted() {
    // this.getMeasurements();
    const jobs = createJobsHash(this.layout);
    this.needsObject = generateJobNeedsDict(jobs);
    this.color = this.initColors();
  },
  methods: {
    getAncestorJob(name) {
      const { groupIdx, stageIdx } = this.pipeline.stagesLookup[name];
      return this.pipeline.stages[stageIdx].groups[groupIdx];
    },
    getMeasurements() {
      this.measurements = {
        width: this.$refs[this.containerId].scrollWidth,
        height: this.$refs[this.containerId].scrollHeight,
      };
    },
    initColors() {
      const colorFn = d3.scaleOrdinal(this.$options.gitLabColorRotation);
      return ({ name }) => colorFn(name);
    },
    onError(payload) {
      this.$emit('error', payload);
    },
    setDropJob(item) {
      this.selectedJob = item;
    },
    setJob(jobName) {
      this.hoveredJobName = jobName;
    },
    setSourceJob(jobName) {
      this.hoveredSourceJobName = jobName;
    },
    slidePipelineContainer() {
      this.$refs.mainPipelineContainer.scrollBy({
        left: ONE_COL_WIDTH,
        top: 0,
        behavior: 'smooth',
      });
    },
    togglePipelineExpanded(jobName, expanded) {
      this.pipelineExpanded = {
        expanded,
        jobName: expanded ? jobName : '',
      };
    },
    updateHighlightedJobs(jobs) {
      this.highlightedJobs = jobs;
    },
  },
};
</script>
<template>
  <div class="js-pipeline-graph">
    <div
      ref="mainPipelineContainer"
      class="gl-justify-content-center gl-display-flex gl-position-relative gl-bg-gray-10 gl-white-space-nowrap gl-border-t-solid gl-border-t-1 gl-border-gray-100"
      :class="{ 'gl-pipeline-min-h gl-py-5 gl-overflow-auto': !isLinkedPipeline }"
    >
      <linked-graph-wrapper>
        <template #upstream>
          <linked-pipelines-column
            v-if="showUpstreamPipelines"
            :config-paths="configPaths"
            :linked-pipelines="upstreamPipelines"
            :column-title="__('Upstream')"
            :show-links="showJobLinks"
            :type="$options.pipelineTypeConstants.UPSTREAM"
            :view-type="viewType"
            @error="onError"
          />
        </template>
        <template #main>
          <div :id="containerId" :ref="containerId" class="gl-display-inline-flex gl-flex-wrap" :style="{ justifyContent: 'space-evenly'}">
            <div v-for="group in allGroups" class="gl-mb-8 gl-mx-6">
              <h3> {{ group.name }} </h3>
              <div class="gl-p-4 gl-text-white gl-font-weight-bold" :style="{ backgroundColor: color(group) }"> {{ group.name }} </div>

              <div v-for="ancestor in needsObject[group.name]">
                <div class="gl-p-4 gl-text-white gl-font-weight-bold" :style="{ backgroundColor: color(getAncestorJob(ancestor)) }"> {{ getAncestorJob(ancestor).name }} </div>

              </div>
            </div>
            <hr />
          </div>
        </template>
        <template #downstream>
          <linked-pipelines-column
            v-if="showDownstreamPipelines"
            class="gl-mr-6"
            :config-paths="configPaths"
            :linked-pipelines="downstreamPipelines"
            :column-title="__('Downstream')"
            :show-links="showJobLinks"
            :type="$options.pipelineTypeConstants.DOWNSTREAM"
            :view-type="viewType"
            @downstreamHovered="setSourceJob"
            @pipelineExpandToggle="togglePipelineExpanded"
            @scrollContainer="slidePipelineContainer"
            @error="onError"
          />
        </template>
      </linked-graph-wrapper>
    </div>
  </div>
</template>
