<script>
import { GlButton, GlTable } from '@gitlab/ui';
import { __ } from '~/locale';
import ActionComponent from './action_component.vue';
import ciIcon from '../../../vue_shared/components/ci_icon.vue';

export default {
  components: {
    ActionComponent,
    ciIcon,
    GlButton,
    GlTable,
  },
  props: {
    stage: {
      type: Object,
      required: true,
    },
    isLinkedPipeline: {
      type: Boolean,
      required: false,
      default: false,
    },
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
  data() {
    return {
      showTable: true,
    }
  },
  computed: {
    expandButtonPosition() {
      return this.isUpstream ? 'gl-left-0 gl-border-r-1!' : 'gl-right-0 gl-border-l-1!';
    },
    expandedIcon() {
      if (this.isUpstream) {
        return this.pipelineExpanded ? 'angle-right' : 'angle-left';
      }
      return this.pipelineExpanded ? 'angle-left' : 'angle-right';
    },
  },
  methods: {
    getFlatJobs(groups) {
      return groups.flatMap(({ jobs }) => jobs);
    },
    pipelineActionRequestComplete() {
      this.$emit('pipelineActionRequestComplete');
    },
    toggleShow() {
      this.showTable = !this.showTable;
    }
  }
}

</script>

<template>
  <div>
    <h4 class="gl-mt-5">
      {{ stage.name }}
      <gl-button
        class="gl-shadow-none! gl-rounded-0!"
        :class="expandButtonPosition"
        :icon="expandedIcon"
        @click="toggleShow"
      />
    </h4>
    <div v-if="showTable">
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
  </div>
</template>
