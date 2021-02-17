<script>
import { GlTable, GlTooltipDirective } from '@gitlab/ui';
import { s__, __ } from '~/locale';
import eventHub from '../../event_hub';
import { PIPELINES_TABLE } from '../../constants';
import PipelinesCommit from './pipelines_commit.vue';
import PipelineManualActions from './pipeline_manual_actions.vue';
import PipelineStage from './stage.vue';
import PipelinesStatusBadge from './pipelines_status_badge.vue';
import PipelineStopModal from './pipeline_stop_modal.vue';
import PipelinesTimeago from './time_ago.vue';
import PipelineTriggerer from './pipeline_triggerer.vue';
import PipelineUrl from './pipeline_url.vue';

const DEFAULT_TD_CLASS = 'gl-p-5!';
const DEFAULT_TH_CLASSES =
  'gl-bg-transparent! gl-border-b-solid! gl-border-b-gray-100! gl-p-5! gl-border-b-1! gl-font-sm!';

export default {
  fields: [
    {
      key: 'status',
      label: s__('Pipeline|Status'),
      thClass: DEFAULT_TH_CLASSES,
      columnClass: 'gl-w-10p',
      tdClass: DEFAULT_TD_CLASS,
      thAttr: { 'data-testid': 'status-th' },
    },
    {
      key: 'pipeline',
      label: s__('Pipeline|Pipeline'),
      thClass: DEFAULT_TH_CLASSES,
      tdClass: DEFAULT_TD_CLASS,
      columnClass: 'gl-w-10p',
      thAttr: { 'data-testid': 'pipeline-th' },
    },
    {
      key: 'triggerer',
      label: s__('Pipeline|Triggerer'),
      thClass: DEFAULT_TH_CLASSES,
      tdClass: DEFAULT_TD_CLASS,
      columnClass: 'gl-w-10p',
      thAttr: { 'data-testid': 'triggerer-th' },
    },
    {
      key: 'commit',
      label: s__('Pipeline|Commit'),
      thClass: DEFAULT_TH_CLASSES,
      tdClass: DEFAULT_TD_CLASS,
      columnClass: 'gl-w-20p',
      thAttr: { 'data-testid': 'commit-th' },
    },
    {
      key: 'stages',
      label: s__('Pipeline|Stages'),
      thClass: DEFAULT_TH_CLASSES,
      tdClass: DEFAULT_TD_CLASS,
      columnClass: 'gl-w-15p',
      thAttr: { 'data-testid': 'stages-th' },
    },
    {
      key: 'timeago',
      label: '',
      thClass: DEFAULT_TH_CLASSES,
      tdClass: DEFAULT_TD_CLASS,
      columnClass: 'gl-w-15p',
      thAttr: { 'data-testid': 'timeago-th' },
    },
    {
      key: 'actions',
      label: '',
      thClass: DEFAULT_TH_CLASSES,
      tdClass: DEFAULT_TD_CLASS,
      columnClass: 'gl-w-20p',
      thAttr: { 'data-testid': 'actions-th' },
    },
  ],
  pipelinesTable: PIPELINES_TABLE,
  components: {
    GlTable,
    PipelinesCommit,
    PipelineManualActions,
    PipelineStage,
    PipelinesStatusBadge,
    PipelineStopModal,
    PipelinesTimeago,
    PipelineTriggerer,
    PipelineUrl,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    pipelines: {
      type: Array,
      required: true,
    },
    pipelineScheduleUrl: {
      type: String,
      required: false,
      default: '',
    },
    updateGraphDropdown: {
      type: Boolean,
      required: false,
      default: false,
    },
    autoDevopsHelpPath: {
      type: String,
      required: true,
    },
    viewType: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      pipelineId: 0,
      pipeline: {},
      endpoint: '',
      cancelingPipeline: null,
    };
  },
  watch: {
    pipelines() {
      this.cancelingPipeline = null;
    },
  },
  created() {
    eventHub.$on('openConfirmationModal', this.setModalData);
  },
  beforeDestroy() {
    eventHub.$off('openConfirmationModal', this.setModalData);
  },
  methods: {
    setModalData(data) {
      this.pipelineId = data.pipeline.id;
      this.pipeline = data.pipeline;
      this.endpoint = data.endpoint;
    },
    onSubmit() {
      eventHub.$emit('postAction', this.endpoint);
      this.cancelingPipeline = this.pipelineId;
    },
  },
};
</script>
<template>
  <div>
    <gl-table
      :fields="$options.fields"
      :items="pipelines"
      :tbody-tr-attr="{ 'data-testid': 'pipeline-table-row' }"
      stacked="lg"
      fixed
    >
      <template #table-colgroup="{ fields }">
        <col v-for="field in fields" :key="field.key" :class="field.columnClass" />
      </template>

      <template #cell(status)="{ item }">
        <pipelines-status-badge :pipeline="item" :viewType="viewType" />
      </template>

      <template #cell(pipeline)="{ item }">
        <pipeline-url
          :pipeline="item"
          :pipeline-schedule-url="pipelineScheduleUrl"
          :auto-devops-help-path="autoDevopsHelpPath"
        />
      </template>

      <template #cell(triggerer)="{ item }">
        <pipeline-triggerer :pipeline="item" />
      </template>

      <template #cell(commit)="{ item }">
        <pipelines-commit :pipeline="item" :viewType="viewType" />
      </template>

      <template #cell(stages)="{ item }">
        <div class="stage-cell">
          <template v-if="item.details.stages.length > 0">
            <div
              v-for="(stage, index) in item.details.stages"
              :key="index"
              class="stage-container dropdown"
              data-testid="widget-mini-pipeline-graph"
            >
              <pipeline-stage
                :type="$options.pipelinesTable"
                :stage="stage"
                :update-dropdown="updateGraphDropdown"
              />
            </div>
          </template>
        </div>
      </template>

      <template #cell(timeago)="{ item }">
        <pipelines-timeago class="gl-text-right" :pipeline="item" />
      </template>

      <template #cell(actions)="{ item }">
        <pipeline-manual-actions :pipeline="item" :canceling-pipeline="cancelingPipeline" />
      </template>
    </gl-table>

    <pipeline-stop-modal :pipeline="pipeline" @submit="onSubmit" />
  </div>
</template>
