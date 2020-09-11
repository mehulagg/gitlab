<script>
import { GlTooltipDirective, GlButton, GlLink, GlLoadingIcon } from '@gitlab/ui';
import CiStatus from '~/vue_shared/components/ci_icon.vue';
import { __, sprintf } from '~/locale';
import { UPSTREAM, DOWNSTREAM } from './constants';

export default {
  name: 'LinkedPipeline',
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  components: {
    CiStatus,
    GlButton,
    GlLink,
    GlLoadingIcon,
  },
  props: {
    columnTitle: {
      type: String,
      required: true,
    },
    expanded: {
      type: Boolean,
      required: true,
    },
    pipeline: {
      type: Object,
      required: true,
    },
    type: {
      type: String,
      required: true,
    },
  },
  computed: {
    tooltipText() {
      return `${this.downstreamTitle} #${this.pipeline.id} - ${this.pipelineStatus.label}
      ${this.sourceJobInfo}`;
    },
    buttonId() {
      return `js-linked-pipeline-${this.pipeline.id}`;
    },
    pipelineStatus() {
      return this.pipeline.status;
    },
    projectName() {
      return this.pipeline.project.name;
    },
    downstreamTitle() {
      return this.pipeline.multiproject ? this.pipeline.project.name : __('child-pipeline');
    },
    parentPipeline() {
      return this.type === UPSTREAM;
    },
    childPipeline() {
      return this.type === DOWNSTREAM;
    },
    label() {
      if (this.pipeline.multiproject) {
        return __('Multi-project');
      }

      if (this.parentPipeline) {
        return __('Parent');
      } else if (this.childPipeline) {
        return __('Child');
      }

    },
    isDownstream() {
      return this.columnTitle === __('Downstream');
    },
    sourceJob() {
      return this.pipeline.sourceJob || this.pipeline.source_job;
    },
    sourceJobInfo() {
      return this.isDownstream
        ? sprintf(__('Created by %{job}'), { job: this.sourceJob.name })
        : '';
    },
    expandedIcon() {
      if (this.parentPipeline) {
        return this.expanded ? 'angle-right' : 'angle-left';
      }
      return this.expanded ? 'angle-left' : 'angle-right';
    },
    expandButtonPosition() {
      return this.parentPipeline ? 'gl-left-0 gl-border-r-1!' : 'gl-right-0 gl-border-l-1!';
    },
  },
  methods: {
    onClickLinkedPipeline() {
      // this.$root.$emit('bv::hide::tooltip', this.buttonId);
      this.hideTooltips();
      this.$emit('pipelineClicked');
      this.$emit('pipelineExpandToggle', this.sourceJob.name, this.expanded);
    },
    hideTooltips() {
      this.$root.$emit('bv::hide::tooltip');
    },
    onDownstreamHovered() {
      this.$emit('downstreamHovered', this.sourceJob.name);
    },
    onDownstreamHoverLeave() {
      this.$emit('downstreamHovered', '');
    },
  },
};
</script>

<template>

  <div
    ref="linkedPipeline"
    v-gl-tooltip
    class="linked-pipeline build"
    :title="tooltipText"
    :class="{ 'downstream-pipeline': isDownstream }"
    data-qa-selector="child_pipeline"
    @mouseover="onDownstreamHovered"
    @mouseleave="onDownstreamHoverLeave"
  >
    <div
      class="gl-relative gl-bg-white gl-p-3 gl-border-solid gl-border-gray-100 gl-border-1"
      :class="{ 'gl-pl-9': parentPipeline }"
    >
      <div class="gl-display-flex">
        <ci-status
          v-if="!pipeline.isLoading"
          :status="pipelineStatus"
          css-classes="gl-top-0 gl-pr-2"
        />
        <div v-else class="gl-pr-2"><gl-loading-icon inline /></div>
        <div class="gl-display-flex gl-flex-direction-column gl-w-13">
          <span class="gl-text-truncate">
            {{ downstreamTitle }}
          </span>
          <div class="gl-text-truncate">
            <gl-link class="gl-text-blue-500!" :href="pipeline.path" data-testid="pipelineLink"
              >#{{ pipeline.id }}</gl-link
            >
          </div>
        </div>
      </div>
      <div class="gl-pt-2">
        <span class="badge badge-primary" data-testid="downstream-pipeline-label">{{ label }}</span>
      </div>
      <gl-button
        :id="buttonId"
        class="gl-absolute gl-top-0 gl-bottom-0 gl-shadow-none! gl-rounded-0!"
        :class="`js-pipeline-expand-${pipeline.id} ${expandButtonPosition}`"
        :icon="expandedIcon"
        data-testid="expandPipelineButton"
        data-qa-selector="expand_pipeline_button"
        @click="onClickLinkedPipeline"
      />
    </div>
  </div>
</template>
