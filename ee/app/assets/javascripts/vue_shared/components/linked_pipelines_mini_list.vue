<script>
import { GlIcon, GlTooltipDirective } from '@gitlab/ui';
import { sprintf, s__ } from '~/locale';

export default {
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  components: {
    GlIcon,
  },
  props: {
    triggeredBy: {
      type: Array,
      required: false,
      default: () => [],
    },
    triggered: {
      type: Array,
      required: false,
      default: () => [],
    },
    pipelinePath: {
      type: String,
      required: false,
      default: '',
    },
  },
  data() {
    return {
      maxRenderedPipelines: 3,
    };
  },
  computed: {
    // Exactly one of these (triggeredBy and triggered) must be truthy. Never both. Never neither.
    isUpstream() {
      return Boolean(this.triggeredBy.length) && !this.triggered.length;
    },
    isDownstream() {
      return !this.triggeredBy.length && Boolean(this.triggered.length);
    },
    linkedPipelines() {
      return this.isUpstream ? this.triggeredBy : this.triggered;
    },
    totalPipelineCount() {
      return this.linkedPipelines.length;
    },
    linkedPipelinesTrimmed() {
      return this.totalPipelineCount > this.maxRenderedPipelines
        ? this.linkedPipelines.slice(0, this.maxRenderedPipelines)
        : this.linkedPipelines;
    },
    shouldRenderCounter() {
      return this.isDownstream && this.linkedPipelines.length > this.maxRenderedPipelines;
    },
    counterLabel() {
      return `+${this.linkedPipelines.length - this.maxRenderedPipelines}`;
    },
    counterTooltipText() {
      return sprintf(s__('LinkedPipelines|%{counterLabel} more downstream pipelines'), {
        counterLabel: this.counterLabel,
      });
    },
  },
  methods: {
    pipelineTooltipText(pipeline) {
      return `${pipeline.project.name} - ${pipeline.details.status.label}`;
    },
    getStatusIcon(iconName) {
      return `${iconName}_borderless`;
    },
    triggerButtonClass(group) {
      return `ci-status-icon-${group}`;
    },
  },
};
</script>

<template>
  <span
    v-if="linkedPipelines"
    :class="{
      'is-upstream': isUpstream,
      'is-downstream': isDownstream,
    }"
    class="linked-pipeline-mini-list inline-block"
  >
    <gl-icon v-if="isDownstream" class="arrow-icon" name="long-arrow" />

    <a
      v-for="pipeline in linkedPipelinesTrimmed"
      :key="pipeline.id"
      v-gl-tooltip="{ title: pipelineTooltipText(pipeline) }"
      :href="pipeline.path"
      :class="triggerButtonClass(pipeline.details.status.group)"
      class="linked-pipeline-mini-item"
    >
      <gl-icon :name="getStatusIcon(pipeline.details.status.icon)" />
    </a>

    <a
      v-if="shouldRenderCounter"
      v-gl-tooltip="{ title: counterTooltipText }"
      :title="counterTooltipText"
      :href="pipelinePath"
      class="linked-pipelines-counter linked-pipeline-mini-item"
    >
      {{ counterLabel }}
    </a>

    <gl-icon v-if="isUpstream" class="arrow-icon" name="long-arrow" />
  </span>
</template>
