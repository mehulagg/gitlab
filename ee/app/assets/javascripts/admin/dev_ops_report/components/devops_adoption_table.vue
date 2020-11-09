<script>
import { GlTable } from '@gitlab/ui';
import { s__ } from '~/locale';
import { DEVOPS_ADOPTION_TABLE_TEST_IDS } from '../constants';
import DevopsAdoptionTableCellFlag from './devops_adoption_table_cell_flag.vue';

const TH_TEST_ID = { 'data-testid': DEVOPS_ADOPTION_TABLE_TEST_IDS.TABLE_HEADERS };
const thClass = 'gl-text-right gl-bg-white!';

export default {
  name: 'DevopsAdoptionTable',
  components: { GlTable, DevopsAdoptionTableCellFlag },
  tableHeaderFields: [
    {
      key: 'segment',
      label: s__('DevopsAdoption|Segment'),
      thClass: 'gl-bg-white!',
      thAttr: TH_TEST_ID,
    },
    {
      key: 'issues',
      label: s__('DevopsAdoption|Issues'),
      thClass,
      thAttr: TH_TEST_ID,
    },
    {
      key: 'merge_requests',
      label: s__('DevopsAdoption|MRs'),
      thClass,
      thAttr: TH_TEST_ID,
    },
    {
      key: 'approvals',
      label: s__('DevopsAdoption|Approvals'),
      thClass,
      thAttr: TH_TEST_ID,
    },
    {
      key: 'runners',
      label: s__('DevopsAdoption|Runners'),
      thClass,
      thAttr: TH_TEST_ID,
    },
    {
      key: 'pipelines',
      label: s__('DevopsAdoption|Pipelines'),
      thClass,
      thAttr: TH_TEST_ID,
    },
    {
      key: 'deploys',
      label: s__('DevopsAdoption|Deploys'),
      thClass,
      thAttr: TH_TEST_ID,
    },
    {
      key: 'scanning',
      label: s__('DevopsAdoption|Scanning'),
      thClass,
      thAttr: TH_TEST_ID,
    },
    {
      key: 'actions',
      label: '',
      thClass: 'gl-bg-white!',
      thAttr: TH_TEST_ID,
    },
  ],
  testids: DEVOPS_ADOPTION_TABLE_TEST_IDS,
};
</script>
<template>
  <gl-table :fields="$options.tableHeaderFields">
    <template #cell(segment)="{ item }">
      <div :data-testid="$options.testids.SEGMENT">
        <strong>{{ item }}</strong>
      </div>
    </template>

    <template #cell(issues)="{ item }">
      <devops-adoption-table-cell-flag :data-testid="$options.testids.ISSUES" :enabled="item" />
    </template>

    <template #cell(mrs)="{ item }">
      <devops-adoption-table-cell-flag :data-testid="$options.testids.MRS" :enabled="item" />
    </template>

    <template #cell(approvals)="{ item }">
      <devops-adoption-table-cell-flag :data-testid="$options.testids.APPROVALS" :enabled="item" />
    </template>

    <template #cell(runners)="{ item }">
      <devops-adoption-table-cell-flag :data-testid="$options.testids.RUNNERS" :enabled="item" />
    </template>

    <template #cell(pipelines)="{ item }">
      <devops-adoption-table-cell-flag :data-testid="$options.testids.PIPELINES" :enabled="item" />
    </template>

    <template #cell(deploys)="{ item }">
      <devops-adoption-table-cell-flag :data-testid="$options.testids.DEPLOYS" :enabled="item" />
    </template>

    <template #cell(scanning)="{ item }">
      <devops-adoption-table-cell-flag :data-testid="$options.testids.SCANNING" :enabled="item" />
    </template>

    <template #cell(actions)>
      <div :data-testid="$options.testids.ACTIONS"></div>
    </template>
  </gl-table>
</template>
