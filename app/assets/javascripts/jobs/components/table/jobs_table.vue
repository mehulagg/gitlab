<script>
import { GlTable } from '@gitlab/ui';
import { __ } from '~/locale';
import CiBadge from '~/vue_shared/components/ci_badge_link.vue';
import JobCell from './cells/job_cell.vue';
import PipelineCell from './cells/pipeline_cell.vue';
import Pipeline from '../../../../../../ee/app/assets/javascripts/compliance_dashboard/components/merge_requests/statuses/pipeline.vue';

const defaultTableClasses = {
  tdClass: 'gl-p-5!',
  thClass: 'gl-bg-transparent! gl-border-b-solid! gl-border-b-gray-100! gl-p-5! gl-border-b-1!',
};

export default {
  fields: [
    {
      key: 'status',
      label: __('Status'),
      ...defaultTableClasses,
      columnClass: 'gl-w-10p',
    },
    {
      key: 'job',
      label: __('Job'),
      ...defaultTableClasses,
      columnClass: 'gl-w-20p',
    },
    {
      key: 'pipeline',
      label: __('Pipeline'),
      ...defaultTableClasses,
      columnClass: 'gl-w-15p',
    },
    {
      key: 'stage',
      label: __('Stage'),
      ...defaultTableClasses,
      columnClass: 'gl-w-10p',
    },
    {
      key: 'name',
      label: __('Name'),
      ...defaultTableClasses,
      columnClass: 'gl-w-15p',
    },
    {
      key: 'duration',
      label: __('Duration'),
      ...defaultTableClasses,
      columnClass: 'gl-w-10p',
    },
    {
      key: 'coverage',
      label: __('Coverage'),
      ...defaultTableClasses,
      columnClass: 'gl-w-10p',
    },
    {
      key: 'actions',
      label: '',
      ...defaultTableClasses,
      columnClass: 'gl-w-10p',
    },
  ],
  components: {
    CiBadge,
    GlTable,
    JobCell,
    PipelineCell,
    Pipeline,
  },
  props: {
    jobs: {
      type: Array,
      required: true,
    },
  },
  methods: {
    formatCoverage(coverage) {
      return coverage ? `${coverage}%` : '';
    },
  },
};
</script>

<template>
  <gl-table :items="jobs" :fields="$options.fields" stacked="lg" fixed>
    <template #table-colgroup="{ fields }">
      <col v-for="field in fields" :key="field.key" :class="field.columnClass" />
    </template>

    <template #cell(status)="{ item }">
      <ci-badge :status="item.detailedStatus" />
    </template>

    <template #cell(job)="{ item }">
      <job-cell :job="item" />
    </template>

    <template #cell(pipeline)="{ item }">
      <pipeline-cell :job="item" />
    </template>

    <template #cell(stage)="{ item }">
      {{ item.stage.name }}
    </template>

    <template #cell(name)="{ item }">
      {{ item.name }}
    </template>

    <template #cell(duration)="{ item }">
      <ci-badge :status="item.detailedStatus" />
    </template>

    <template #cell(coverage)="{ item }">
      {{ formatCoverage(item.coverage) }}
    </template>

    <template #cell(actions)="{ item }">
      <ci-badge :status="item.detailedStatus" />
    </template>
  </gl-table>
</template>
