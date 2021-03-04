<script>
import { GlButton } from '@gitlab/ui';
import { __ } from '~/locale';
import StageList from './stage_list.vue';
import LinkedList from './linked_list.vue'
import { DOWNSTREAM, MAIN, UPSTREAM, ONE_COL_WIDTH } from './constants';

export default {
  name: 'PipelineList',
  components: {
    GlButton,
    LinkedList,
    StageList
  },
  props: {
    pipeline: {
      type: Object,
      required: true,
    },
    isLinkedPipeline: {
      type: Boolean,
      required: false,
      default: false,
    },
    type: {
      type: String,
      required: false,
      default: MAIN,
    },
  },
  data() {
    return {
      showMain: true,
    }
  },
  pipelineTypeConstants: {
    DOWNSTREAM,
    MAIN,
    UPSTREAM,
  },
  computed: {
    downstreamPipelines() {
      return this.pipeline.downstream ? this.pipeline.downstream : [];
    },
    expandButtonPosition() {
      return this.isUpstream ? 'gl-left-0 gl-border-r-1!' : 'gl-right-0 gl-border-l-1!';
    },
    expandedIcon() {
      if (this.isUpstream) {
        return this.pipelineExpanded ? 'angle-right' : 'angle-left';
      }
      return this.pipelineExpanded ? 'angle-left' : 'angle-right';
    },
    graph() {
      return this.pipeline.stages;
    },
    hasDownstreamPipelines() {
      return Boolean(this.pipeline?.downstream?.length > 0);
    },
    hasUpstreamPipelines() {
      return Boolean(this.pipeline?.upstream?.length > 0);
    },
    upstreamPipelines() {
      return this.hasUpstreamPipelines ? this.pipeline.upstream : [];
    },
  },
  methods: {
    onError(err) {
      console.log(err);
    },
    toggleMain() {
      this.showMain = !this.showMain;
    }
  },
}
</script>

<template>
  <div>
    <h3 v-if="type === $options.pipelineTypeConstants.MAIN">
      Pipeline #{{ pipeline.iid }}
      <gl-button
        class="gl-shadow-none! gl-rounded-0!"
        :class="`js-pipeline-expand-${pipeline.id} ${expandButtonPosition}`"
        :icon="expandedIcon"
        @click="toggleMain"
      />
    </h3>
    <div>
      <stage-list
        v-if="showMain"
        v-for="stage in graph"
        :stage="stage"
        :key="stage.name"
      />
    </div>
    <linked-list
      v-if="hasUpstreamPipelines"
      class="gl-mb-8"
      :linked-pipelines="upstreamPipelines"
      :column-title="__('Upstream Pipelines')"
      :type="$options.pipelineTypeConstants.UPSTREAM"
      @error="onError"
    />
    <linked-list
      v-if="hasDownstreamPipelines"
      class="gl-mb-8"
      :linked-pipelines="downstreamPipelines"
      :column-title="__('Downstream Pipelines')"
      :type="$options.pipelineTypeConstants.DOWNSTREAM"
      @error="onError"
    />
  </div>
</template>
