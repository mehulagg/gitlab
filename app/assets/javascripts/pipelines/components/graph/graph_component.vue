<script>
import { escape, capitalize } from 'lodash';
import { GlLoadingIcon } from '@gitlab/ui';
import StageColumnComponent from './stage_column_component.vue';
import GraphMixin from '../../mixins/graph_component_mixin.js';
import GraphWidthMixin from '../../mixins/graph_width_mixin';
import LinkedPipelinesColumn from './linked_pipelines_column.vue';
import GraphBundleMixin from '../../mixins/graph_pipeline_bundle_mixin';
import getPipelineDetails from '../../graphql/queries/get_pipeline_details.query.graphql';
import { UPSTREAM, DOWNSTREAM, MAIN } from './constants';
import { unwrapPipelineData } from './utils';
import SfGraphStreamy from '../pipeline_graph/sf_graph_streamy.vue';
import SfGraphLinks from '../pipeline_graph/sf_graph_links.vue';
import { parseData } from '../parsing_utils';

export default {
  name: 'PipelineGraph',
  components: {
    SfGraphLinks,
    SfGraphStreamy,
    StageColumnComponent,
    GlLoadingIcon,
    LinkedPipelinesColumn,
  },
  mixins: [GraphMixin, GraphWidthMixin],
  inject: {
    pipelineIid: {
      default: '',
    },
    pipelineProjectPath: {
      default: '',
    },
  },
  props: {
    isLinkedPipeline: {
      type: Boolean,
      required: false,
      default: false,
    },
    pipeline: {
      type: Object,
      required: true,
    },
    type: {
      type: String,
      required: false,
      default: MAIN,
    },
  },
  data() {
    return {
      jobName: null,
      pipelineExpanded: {
        jobName: '',
        expanded: false,
      },
      highlightedJob: '',
      highlightedJobs: [],
    };
  },
  apollo: {
    pipeline: {
      query: getPipelineDetails,
      variables() {
        return {
          projectPath: this.pipelineProjectPath,
          iid: this.pipelineIid,
        };
      },
      update(data) {
        return unwrapPipelineData(this.pipelineIid, data);
      },
      error(err) {
        console.error('graphQL error:', err);
      },
    },
  },
  pipelineTypeConstants: {
    UPSTREAM,
    DOWNSTREAM,
  },
  CONTAINER_REF: 'PIPELINE_GRAPH_CONTAINER_REF',
  CONTAINER_ID: 'pipeline-graph-container',
  computed: {
    downstreamPipelines() {
      return this.hasDownstreamPipelines ? this.pipeline.downstream : [];
    },
    graphLoading() {
      return this.$apollo.queries.pipeline.loading;
    },
    hasDownstreamPipelines() {
      return Boolean(this.pipeline?.downstream?.length > 0);
    },
    hasUpstreamPipelines() {
      return Boolean(this.pipeline?.upstream?.length > 0);
    },
    linksData(){
      // obviously this is gross and needs to be better rectified
      const makeDAGstyleNodes = (pipeline) => {
        const { stages } = pipeline;

        const unwrappedGroups = stages
          .map(({ name, groups }) => {
            return groups.map(group => {
              return { category: name, ...group };
            });
          })
          .flat(2);

        return unwrappedGroups;
      }

      const { nodeDict } = parseData(makeDAGstyleNodes(this.pipeline));
      return { jobs: nodeDict, stages: this.pipeline.stages };
    },
    // The two show checks prevent upstream / downstream from showing redundant linked columns
    showDownstreamPipelines() {
      return (
        this.hasDownstreamPipelines && this.type !== this.$options.pipelineTypeConstants.UPSTREAM
      );
    },
    showUpstreamPipelines() {
      return (
        this.hasUpstreamPipelines && this.type !== this.$options.pipelineTypeConstants.DOWNSTREAM
      );
    },
    stages() {
      return this.pipeline?.stages;
    },
    upstreamPipelines() {
      return this.hasUpstreamPipelines ? this.pipeline.upstream : [];
    },
  },
  methods: {
    hasOnlyOneJob(stage) {
      return stage.groups.length === 1;
    },

    highlightNeeds(uniqueJobId) {
      this.highlightedJob = uniqueJobId;
    },

    removeHighlightNeeds() {
      this.highlightedJob = '';
    },

    setJob(jobName) {
      this.jobName = jobName;
    },

    setHighlightedJobs(highlightedJobs) {
      this.highlightedJobs = highlightedJobs;
    },

    setPipelineExpanded(jobName, expanded) {
      if (expanded) {
        this.pipelineExpanded = {
          jobName,
          expanded,
        };
      } else {
        this.pipelineExpanded = {
          expanded,
          jobName: '',
        };
      }
    },
  },
};
</script>

<template>
  <div>
    <div class="build-content middle-block js-pipeline-graph">
      <div
        class="pipeline-visualization pipeline-graph pipeline-min-h gl-position-relative gl-overflow-auto gl-bg-gray-10"
        :class="{ 'gl-py-5': !isLinkedPipeline }"
        :id="$options.CONTAINER_ID"
        :ref="$options.CONTAINER_REF"
      >
      <sf-graph-links
        :pipeline-data="linksData"
        :highlighted-job="highlightedJob"
        :container-id="$options.CONTAINER_ID"
        :container-ref="$options.CONTAINER_REF"
        @on-highlighted-jobs-change="setHighlightedJobs"
      >
        <sf-graph-streamy>
          <template #upstream>
            <linked-pipelines-column
              v-if="showUpstreamPipelines"
              :linked-pipelines="upstreamPipelines"
              :column-title="__('Upstream')"
              :type="$options.pipelineTypeConstants.UPSTREAM"
            />
          </template>

          <template #main>
            <template v-if="!graphLoading">
                <stage-column-component
                  v-for="(stage, index) in stages"
                  :key="stage.name"
                  :class="{
                    'has-only-one-job': hasOnlyOneJob(stage),
                    'gl-mr-26': shouldAddRightMargin(index),
                    'has-upstream gl-ml-11': hasUpstreamPipelines,
                  }"
                  :title="capitalizeStageName(stage.name)"
                  :groups="stage.groups"
                  :stage-connector-class="stageConnectorClass(index, stage)"
                  :is-first-column="isFirstColumn(index)"
                  :job-hovered="jobName"
                  :action="stage.status.action"
                  :pipeline-expanded="pipelineExpanded"
                  @refreshPipelineGraph="refreshPipelineGraph"
                  @job-for-link-mouseenter="highlightNeeds"
                  @job-for-link-mouseoff="removeHighlightNeeds"
                />
            </template>
          </template>

          <template #downstream>
            <linked-pipelines-column
              v-if="showDownstreamPipelines"
              :linked-pipelines="downstreamPipelines"
              :column-title="__('Downstream')"
              :type="$options.pipelineTypeConstants.DOWNSTREAM"
              @downstreamHovered="setJob"
              @pipelineExpandToggle="setPipelineExpanded"
            />
          </template>
        </sf-graph-streamy>
        </sf-graph-links>

      </div>
    </div>
  </div>
</template>
