<script>
import { GlButton, GlTable } from '@gitlab/ui';
import { __ } from '~/locale';
import ciIcon from '../../../vue_shared/components/ci_icon.vue';
import ActionComponent from './action_component.vue';
import LinkedList from './linked_list.vue'
import { DOWNSTREAM, MAIN, UPSTREAM, ONE_COL_WIDTH } from './constants';

export default {
  name: 'PipelineList',
  components: {
    // LinkedPipeline,
    ActionComponent,
    ciIcon,
    GlTable,
    GlButton,
    LinkedList,
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
  fields: [
    {
      key: 'status',
      label: __('Status'),
      thClass: 'gl-w-10p',
    },
    {
      key: 'name',
      label: __('Name'),
      thClass: 'gl-w-40p',
    },
    {
      key: 'needs',
      label: __('Needs'),
      thClass: 'gl-w-40p',
    },
    {
      key: 'action',
      label: '',
      thClass: 'gl-w-10p',
    },
  ],
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
    getFlatJobs(groups) {
      return groups.flatMap(({ jobs }) => jobs);
    },
    onError(err) {
      console.log(err);
    },
    pipelineActionRequestComplete() {
      this.$emit('pipelineActionRequestComplete');
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
    <div
      v-if="showMain"
      v-for="stage in graph">
      <h4 class="gl-mt-5">
        {{ stage.name }}
      </h4>
      <gl-table :items="getFlatJobs(stage.groups)" :fields="$options.fields">
        <template #cell(status)="data">
          <ci-icon :size="16" :status="data.item.status" class="gl-line-height-0" />
        </template>
        <template #cell(action)="data">
          <div class="gl-relative">
            <action-component
              v-if="data.item.status.action"
              :tooltip-text="data.item.status.action.title"
              :link="data.item.status.action.path"
              :action-icon="data.item.status.action.icon"
              @pipelineActionRequestComplete="pipelineActionRequestComplete"
              />
            </div>
        </template>
        <template #cell(needs)="data">
          <span>{{ data.item.needs.join(', ') }}</span>
        </template>
      </gl-table>
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
