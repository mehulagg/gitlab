<script>
import { GlTable, GlButton } from '@gitlab/ui';
import { s__ } from '~/locale';
import DevopsAdoptionTableCellFlag from './devops_adoption_table_cell_flag.vue';
import { DEVOPS_ADOPTION_TABLE_TEST_IDS } from '../constants';

const fieldOptions = {
  thClass: 'gl-bg-white! gl-text-gray-400',
  thAttr: { 'data-testid': DEVOPS_ADOPTION_TABLE_TEST_IDS.TABLE_HEADERS },
};

export default {
  name: 'DevopsAdoptionTable',
  components: { GlTable, DevopsAdoptionTableCellFlag, GlButton },
  tableHeaderFields: [
    {
      key: 'name',
      label: s__('DevopsAdoption|Segment'),
      ...fieldOptions,
    },
    {
      key: 'issueOpened',
      label: s__('DevopsAdoption|Issues'),
      ...fieldOptions,
    },
    {
      key: 'mergeRequestOpened',
      label: s__('DevopsAdoption|MRs'),
      ...fieldOptions,
    },
    {
      key: 'mergeRequestApproved',
      label: s__('DevopsAdoption|Approvals'),
      ...fieldOptions,
    },
    {
      key: 'runnerConfigured',
      label: s__('DevopsAdoption|Runners'),
      ...fieldOptions,
    },
    {
      key: 'pipelineSucceeded',
      label: s__('DevopsAdoption|Pipelines'),
      ...fieldOptions,
    },
    {
      key: 'deploySucceeded',
      label: s__('DevopsAdoption|Deploys'),
      ...fieldOptions,
    },
    {
      key: 'securityScanSucceeded',
      label: s__('DevopsAdoption|Scanning'),
      ...fieldOptions,
    },
    {
      key: 'actions',
      label: '',
      tdClass: 'actions-cell',
      ...fieldOptions,
    },
  ],
  testids: DEVOPS_ADOPTION_TABLE_TEST_IDS,
  props: {
    segments: {
      type: Array,
      required: true,
    },
  },
};
</script>
<template>
  <gl-table
    :fields="$options.tableHeaderFields"
    :items="segments"
    thead-class="gl-border-t-0 gl-border-b-solid gl-border-b-1 gl-border-b-gray-100"
    stacked="sm"
  >
    <template #cell(name)="{ item }">
      <div :data-testid="$options.testids.SEGMENT">
        <strong>{{ item.name }}</strong>
      </div>
    </template>

    <template #cell(issueOpened)="{ item }">
      <devops-adoption-table-cell-flag
        :data-testid="$options.testids.ISSUES"
        :enabled="item.latestSnapshot.issueOpened"
      />
    </template>

    <template #cell(mergeRequestOpened)="{ item }">
      <devops-adoption-table-cell-flag
        :data-testid="$options.testids.MRS"
        :enabled="item.latestSnapshot.mergeRequestOpened"
      />
    </template>

    <template #cell(mergeRequestApproved)="{ item }">
      <devops-adoption-table-cell-flag
        :data-testid="$options.testids.APPROVALS"
        :enabled="item.latestSnapshot.mergeRequestApproved"
      />
    </template>

    <template #cell(runnerConfigured)="{ item }">
      <devops-adoption-table-cell-flag
        :data-testid="$options.testids.RUNNERS"
        :enabled="item.latestSnapshot.runnerConfigured"
      />
    </template>

    <template #cell(pipelineSucceeded)="{ item }">
      <devops-adoption-table-cell-flag
        :data-testid="$options.testids.PIPELINES"
        :enabled="item.latestSnapshot.pipelineSucceeded"
      />
    </template>

    <template #cell(deploySucceeded)="{ item }">
      <devops-adoption-table-cell-flag
        :data-testid="$options.testids.DEPLOYS"
        :enabled="item.latestSnapshot.deploySucceeded"
      />
    </template>

    <template #cell(securityScanSucceeded)="{ item }">
      <devops-adoption-table-cell-flag
        :data-testid="$options.testids.SCANNING"
        :enabled="item.latestSnapshot.securityScanSucceeded"
      />
    </template>

    <template #cell(actions)>
      <div :data-testid="$options.testids.ACTIONS">
        <gl-button category="tertiary" icon="ellipsis_h" />
      </div>
    </template>
  </gl-table>
</template>
