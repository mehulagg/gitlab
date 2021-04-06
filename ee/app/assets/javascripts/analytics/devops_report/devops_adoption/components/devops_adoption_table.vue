<script>
import {
  GlTable,
  GlButton,
  GlModalDirective,
  GlTooltipDirective,
  GlIcon,
  GlBadge,
} from '@gitlab/ui';
import LocalStorageSync from '~/vue_shared/components/local_storage_sync.vue';
import {
  DEVOPS_ADOPTION_TABLE_TEST_IDS,
  DEVOPS_ADOPTION_STRINGS,
  DEVOPS_ADOPTION_SEGMENT_MODAL_ID,
  DEVOPS_ADOPTION_SEGMENT_DELETE_MODAL_ID,
  DEVOPS_ADOPTION_SEGMENTS_TABLE_SORT_BY_STORAGE_KEY,
  DEVOPS_ADOPTION_SEGMENTS_TABLE_SORT_DESC_STORAGE_KEY,
} from '../constants';
import DevopsAdoptionDeleteModal from './devops_adoption_delete_modal.vue';
import DevopsAdoptionTableCellFlag from './devops_adoption_table_cell_flag.vue';

const NAME_HEADER = 'name';

const formatter = (value, key, item) => {
  if (key === NAME_HEADER) {
    return item.namespace?.fullName;
  }

  if (item.latestSnapshot && item.latestSnapshot[key] === false) {
    return 1;
  } else if (item.latestSnapshot && item.latestSnapshot[key]) {
    return 2;
  }

  return 0;
};

const fieldOptions = {
  thClass: 'gl-bg-white! gl-text-gray-400',
  thAttr: { 'data-testid': DEVOPS_ADOPTION_TABLE_TEST_IDS.TABLE_HEADERS },
  formatter,
  sortable: true,
  sortByFormatted: true,
};

const { table: i18n } = DEVOPS_ADOPTION_STRINGS;

const headers = [
  NAME_HEADER,
  'issueOpened',
  'mergeRequestOpened',
  'mergeRequestApproved',
  'runnerConfigured',
  'pipelineSucceeded',
  'deploySucceeded',
  'securityScanSucceeded',
].map((key) => ({ key, ...i18n.headers[key], ...fieldOptions }));

export default {
  name: 'DevopsAdoptionTable',
  components: {
    GlTable,
    DevopsAdoptionTableCellFlag,
    GlButton,
    LocalStorageSync,
    DevopsAdoptionDeleteModal,
    GlIcon,
    GlBadge,
  },
  i18n,
  devopsSegmentModalId: DEVOPS_ADOPTION_SEGMENT_MODAL_ID,
  devopsSegmentDeleteModalId: DEVOPS_ADOPTION_SEGMENT_DELETE_MODAL_ID,
  directives: {
    GlTooltip: GlTooltipDirective,
    GlModal: GlModalDirective,
  },
  inject: {
    groupGid: {
      default: null,
    },
  },
  tableHeaderFields: [
    ...headers,
    {
      key: 'actions',
      tdClass: 'actions-cell',
      ...fieldOptions,
      sortable: false,
    },
  ],
  testids: DEVOPS_ADOPTION_TABLE_TEST_IDS,
  sortByStorageKey: DEVOPS_ADOPTION_SEGMENTS_TABLE_SORT_BY_STORAGE_KEY,
  sortDescStorageKey: DEVOPS_ADOPTION_SEGMENTS_TABLE_SORT_DESC_STORAGE_KEY,
  props: {
    segments: {
      type: Array,
      required: true,
    },
    selectedSegment: {
      type: Object,
      required: false,
      default: null,
    },
  },
  data() {
    return {
      sortBy: NAME_HEADER,
      sortDesc: false,
    };
  },
  methods: {
    setSelectedSegment(segment) {
      this.$emit('set-selected-segment', segment);
    },
    slotName(key) {
      return `head(${key})`;
    },
    isCurrentGroup(item) {
      return item.namespace?.id === this.groupGid;
    },
  },
};
</script>
<template>
  <div>
    <local-storage-sync
      v-model="sortBy"
      :storage-key="$options.sortByStorageKey"
      :data-testid="$options.testids.LOCAL_STORAGE_SORT_BY"
      as-json
    />
    <local-storage-sync
      v-model="sortDesc"
      :storage-key="$options.sortDescStorageKey"
      :data-testid="$options.testids.LOCAL_STORAGE_SORT_DESC"
      as-json
    />
    <gl-table
      :fields="$options.tableHeaderFields"
      :items="segments"
      :sort-by.sync="sortBy"
      :sort-desc.sync="sortDesc"
      thead-class="gl-border-t-0 gl-border-b-solid gl-border-b-1 gl-border-b-gray-100"
      stacked="sm"
    >
      <template v-for="header in $options.tableHeaderFields" #[slotName(header.key)]>
        <div :key="header.key" class="gl-display-flex gl-align-items-center">
          <span>{{ header.label }}</span>
          <gl-icon
            v-if="header.tooltip"
            v-gl-tooltip.hover="header.tooltip"
            name="information-o"
            class="gl-text-gray-200 gl-ml-1"
            :size="14"
          />
        </div>
      </template>

      <template #cell(name)="{ item }">
        <div :data-testid="$options.testids.SEGMENT">
          <strong v-if="item.latestSnapshot">{{ item.namespace.fullName }}</strong>
          <template v-else>
            <span class="gl-text-gray-400">{{ item.namespace.fullName }}</span>
            <gl-icon name="hourglass" class="gl-text-gray-400" />
          </template>
          <gl-badge v-if="isCurrentGroup(item)" class="gl-ml-1" variant="info">{{
            __('This group')
          }}</gl-badge>
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
          <gl-button
            v-gl-modal="$options.devopsSegmentDeleteModalId"
            v-gl-tooltip.hover="$options.i18n.removeButton"
            category="tertiary"
            icon="remove"
            @click="setSelectedSegment(item)"
          />
        </div>
      </template>
    </gl-table>
    <devops-adoption-delete-modal
      v-if="selectedSegment"
      :segment="selectedSegment"
      @trackModalOpenState="$emit('trackModalOpenState', $event)"
    />
  </div>
</template>
