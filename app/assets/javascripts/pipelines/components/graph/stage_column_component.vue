<script>
import { isEmpty, escape } from 'lodash';
import stageColumnMixin from '../../mixins/stage_column_mixin';
import JobItem from './job_item.vue';
import JobGroupDropdown from './job_group_dropdown.vue';
import ActionComponent from './action_component.vue';
import SfGraph from '../pipeline_graph/sf_graph.vue';
import SfGraphLinks from '../pipeline_graph/sf_graph_links.vue';

export default {
  components: {
    JobItem,
    JobGroupDropdown,
    ActionComponent,
    SfGraph,
    SfGraphLinks,
  },
  mixins: [stageColumnMixin],
  props: {
    title: {
      type: String,
      required: true,
    },
    groups: {
      type: Array,
      required: true,
    },
    isFirstColumn: {
      type: Boolean,
      required: false,
      default: false,
    },
    stageConnectorClass: {
      type: String,
      required: false,
      default: '',
    },
    action: {
      type: Object,
      required: false,
      default: () => ({}),
    },
    jobHovered: {
      type: String,
      required: false,
      default: '',
    },
    pipelineExpanded: {
      type: Object,
      required: false,
      default: () => ({}),
    },
  },
  computed: {
    hasAction() {
      return !isEmpty(this.action);
    },
  },
  methods: {
    groupId(group) {
      return `ci-badge-${escape(group.name)}`;
    },
    pipelineActionRequestComplete() {
      this.$emit('refreshPipelineGraph');
    },
  },
};
</script>
<template>

    <sf-graph>
      <template #stages>
        {{ title }}
        <action-component
          v-if="hasAction"
          :action-icon="action.icon"
          :tooltip-text="action.title"
          :link="action.path"
          class="js-stage-action stage-action rounded"
          @pipelineActionRequestComplete="pipelineActionRequestComplete"
        />
      </template>
      <template #jobs>
        <div
          v-for="(group, index) in groups"
          :id="groupId(group)"
          :key="group.id || group.name"
          class="build"
        >
          <job-item
            v-if="group.size === 1"
            :job="group.jobs[0]"
            :job-hovered="jobHovered"
            :pipeline-expanded="pipelineExpanded"
            css-class-job-name="build-content"
            @pipelineActionRequestComplete="pipelineActionRequestComplete"
            @on-mouse-enter="highlightNeeds(job.name)"
            @on-mouse-leave="removeHighlightNeeds(job.name)"
          />

          <job-group-dropdown
            v-else
            :group="group"
            @pipelineActionRequestComplete="pipelineActionRequestComplete"
            @on-mouse-enter="highlightNeeds(group.name)"
            @on-mouse-leave="removeHighlightNeeds(group.name)"
          />
        </div>
      </template>
    </sf-graph>
</template>
