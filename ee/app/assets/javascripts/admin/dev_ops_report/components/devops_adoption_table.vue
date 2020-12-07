<script>
import { GlTable, GlButton, GlPopover, GlModalDirective } from '@gitlab/ui';
import { s__ } from '~/locale';
import DevopsAdoptionTableCellFlag from './devops_adoption_table_cell_flag.vue';
import DevopsAdoptionDeleteModal from './devops_adoption_delete_modal.vue';
import {
  DEVOPS_ADOPTION_TABLE_TEST_IDS,
  DEVOPS_ADOPTION_STRINGS,
  DEVOPS_ADOPTION_SEGMENT_MODAL_ID,
  DEVOPS_ADOPTION_SEGMENT_DELETE_MODAL_ID,
} from '../constants';

const fieldOptions = {
  thClass: 'gl-bg-white! gl-text-gray-400',
  thAttr: { 'data-testid': DEVOPS_ADOPTION_TABLE_TEST_IDS.TABLE_HEADERS },
};

export default {
  name: 'DevopsAdoptionTable',
  components: {
    GlTable,
    DevopsAdoptionTableCellFlag,
    GlButton,
    GlPopover,
    DevopsAdoptionDeleteModal,
  },
  i18n: DEVOPS_ADOPTION_STRINGS.table,
  devopsSegmentModalId: DEVOPS_ADOPTION_SEGMENT_MODAL_ID,
  devopsSegmentDeleteModalId: DEVOPS_ADOPTION_SEGMENT_DELETE_MODAL_ID,
  directives: {
    GlModal: GlModalDirective,
  },
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
  data() {
    return {
      selectedSegment: null,
    };
  },
  methods: {
    popoverContainerId(name) {
      return `popover_container_id_for_${name}`;
    },
    popoverId(name) {
      return `popover_id_for_${name}`;
    },
    setSelectedSegment(segment) {
      this.selectedSegment = segment;
    },
  },
};
</script>
<template>
  <div>
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
          v-if="item.latestSnapshot"
          :data-testid="$options.testids.ISSUES"
          :enabled="item.latestSnapshot.issueOpened"
        />
      </template>

      <template #cell(mergeRequestOpened)="{ item }">
        <devops-adoption-table-cell-flag
          v-if="item.latestSnapshot"
          :data-testid="$options.testids.MRS"
          :enabled="item.latestSnapshot.mergeRequestOpened"
        />
      </template>

      <template #cell(mergeRequestApproved)="{ item }">
        <devops-adoption-table-cell-flag
          v-if="item.latestSnapshot"
          :data-testid="$options.testids.APPROVALS"
          :enabled="item.latestSnapshot.mergeRequestApproved"
        />
      </template>

      <template #cell(runnerConfigured)="{ item }">
        <devops-adoption-table-cell-flag
          v-if="item.latestSnapshot"
          :data-testid="$options.testids.RUNNERS"
          :enabled="item.latestSnapshot.runnerConfigured"
        />
      </template>

      <template #cell(pipelineSucceeded)="{ item }">
        <devops-adoption-table-cell-flag
          v-if="item.latestSnapshot"
          :data-testid="$options.testids.PIPELINES"
          :enabled="item.latestSnapshot.pipelineSucceeded"
        />
      </template>

      <template #cell(deploySucceeded)="{ item }">
        <devops-adoption-table-cell-flag
          v-if="item.latestSnapshot"
          :data-testid="$options.testids.DEPLOYS"
          :enabled="item.latestSnapshot.deploySucceeded"
        />
      </template>

      <template #cell(securityScanSucceeded)="{ item }">
        <devops-adoption-table-cell-flag
          v-if="item.latestSnapshot"
          :data-testid="$options.testids.SCANNING"
          :enabled="item.latestSnapshot.securityScanSucceeded"
        />
      </template>

      <template #cell(actions)="{ item }">
        <div :data-testid="$options.testids.ACTIONS">
          <gl-button :id="popoverId(item.name)" category="tertiary" icon="ellipsis_h" />
          <div :id="popoverContainerId(item.name)">
            <gl-popover
              :target="popoverId(item.name)"
              :container="popoverContainerId(item.name)"
              triggers="hover focus"
              placement="left"
              show
            >
              <div class="gl-display-inline-flex gl-flex-direction-column">
                <gl-button
                  v-gl-modal="$options.devopsSegmentModalId"
                  category="tertiary"
                  class="gl-w-max-content"
                  @click="setSelectedSegment(item)"
                  >{{ $options.i18n.editButton }}</gl-button
                >
                <gl-button
                  v-gl-modal="$options.devopsSegmentDeleteModalId"
                  category="tertiary"
                  variant="danger"
                  @click="setSelectedSegment(item)"
                  >{{ $options.i18n.deleteButton }}</gl-button
                >
              </div>
            </gl-popover>
          </div>
        </div>
      </template>
    </gl-table>
    <devops-adoption-delete-modal v-if="selectedSegment" :segment="selectedSegment" />
  </div>
</template>
