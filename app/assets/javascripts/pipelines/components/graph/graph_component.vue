<script>
import { escape, capitalize } from 'lodash';
import { GlLoadingIcon } from '@gitlab/ui';
import StageColumnComponent from './stage_column_component.vue';
import GraphWidthMixin from '../../mixins/graph_width_mixin';
import LinkedPipelinesColumn from './linked_pipelines_column.vue';
import GraphBundleMixin from '../../mixins/graph_pipeline_bundle_mixin';
import getPipelineDetails from '../../graphql/queries/get_pipeline_details.query.graphql';
import { UPSTREAM, DOWNSTREAM, MAIN } from './constants';
import { unwrapPipelineData } from './utils';

export default {
  name: 'PipelineGraph',
  components: {
    StageColumnComponent,
    GlLoadingIcon,
    LinkedPipelinesColumn,
  },
  mixins: [
    GraphMixin,
    GraphWidthMixin,
  ],
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
      error(err){
        console.error('graphQL error:', err);
      }
    }
  },
  pipelineTypeConstants: {
     UPSTREAM,
     DOWNSTREAM,
  },
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
    // The two show checks prevent upstream / downstream from showing redundant linked columns
    showDownstreamPipelines() {
      return this.hasDownstreamPipelines && this.type !== this.$options.pipelineTypeConstants.UPSTREAM;
    },
    showUpstreamPipelines() {
      return this.hasUpstreamPipelines && this.type !== this.$options.pipelineTypeConstants.DOWNSTREAM;
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

    setJob(jobName) {
      this.jobName = jobName;
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
  }
};
</script>

<template>
  <div>
    <div class="build-content middle-block js-pipeline-graph">
      <div
        class="pipeline-visualization pipeline-graph"
        :class="{ 'pipeline-tab-content': !isLinkedPipeline }"
      >
        <div
          :style="{
            paddingLeft: `${graphLeftPadding}px`,
            paddingRight: `${graphRightPadding}px`,
          }"
          class="gl-display-flex"
        >

        <linked-pipelines-column
          v-if="showUpstreamPipelines"
          :linked-pipelines="upstreamPipelines"
          :column-title="__('Upstream')"
          :type="$options.pipelineTypeConstants.UPSTREAM"
        />

        <ul
            class="stage-column-list align-top"
            :class="{
              'inline js-has-linked-pipelines': hasUpstreamPipelines || hasDownstreamPipelines,
            }"
            v-if="!graphLoading"
          >
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
            />
          </ul>

          <linked-pipelines-column
            v-if="showDownstreamPipelines"
            :linked-pipelines="downstreamPipelines"
            :column-title="__('Downstream')"
            :type="$options.pipelineTypeConstants.DOWNSTREAM"
            @downstreamHovered="setJob"
            @pipelineExpandToggle="setPipelineExpanded"
          />

        </div>
      </div>
    </div>
  </div>
</template>
