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
  DA_TABLE_TEST_IDS_HEADERS,
  DA_TABLE_TEST_IDS_NAMESPACE,
  DA_TABLE_TEST_IDS_ACTIONS,
  DA_TABLE_TEST_IDS_LOCAL_STORAGE_SORT_BY,
  DA_TABLE_TEST_IDS_LOCAL_STORAGE_SORT_DESC,
  DA_DELETE_MODAL_ID,
  DA_TABLE_SORT_BY_STORAGE_KEY,
  DA_TABLE_SORT_DESC_STORAGE_KEY,
  DA_TABLE_REMOVE_BUTTON,
  DA_TABLE_REMOVE_BUTTON_DISABLED,
  DA_GROUP_COL_LABEL,
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
  thAttr: { 'data-testid': DA_TABLE_TEST_IDS_HEADERS },
  formatter,
  sortable: true,
  sortByFormatted: true,
};

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
  directives: {
    GlTooltip: GlTooltipDirective,
    GlModal: GlModalDirective,
  },
  inject: {
    groupGid: {
      default: null,
    },
  },
  i18n: {
    removeButtonDisabled: DA_TABLE_REMOVE_BUTTON_DISABLED,
    removeButton: DA_TABLE_REMOVE_BUTTON,
  },
  deleteModalId: DA_DELETE_MODAL_ID,
  testids: {
    NAMESPACE: DA_TABLE_TEST_IDS_NAMESPACE,
    ACTIONS: DA_TABLE_TEST_IDS_ACTIONS,
    LOCAL_STORAGE_SORT_BY: DA_TABLE_TEST_IDS_LOCAL_STORAGE_SORT_BY,
    LOCAL_STORAGE_SORT_DESC: DA_TABLE_TEST_IDS_LOCAL_STORAGE_SORT_DESC,
  },
  sortByStorageKey: DA_TABLE_SORT_BY_STORAGE_KEY,
  sortDescStorageKey: DA_TABLE_SORT_DESC_STORAGE_KEY,
  props: {
    enabledNamespaces: {
      type: Array,
      required: true,
    },
    cols: {
      type: Array,
      required: true,
    },
  },
  data() {
    return {
      sortBy: NAME_HEADER,
      sortDesc: false,
      selectedNamespace: null,
    };
  },
  computed: {
    tableHeaderFields() {
      return [
        {
          key: 'name',
          label: DA_GROUP_COL_LABEL,
          ...fieldOptions,
        },
        ...this.cols.map((item) => ({
          ...item,
          ...fieldOptions,
        })),
        {
          key: 'actions',
          tdClass: 'actions-cell',
          ...fieldOptions,
          sortable: false,
        },
      ];
    },
  },
  methods: {
    setSelectedNamespace(namespace) {
      this.selectedNamespace = namespace;
    },
    headerSlotName(key) {
      return `head(${key})`;
    },
    cellSlotName(key) {
      return `cell(${key})`;
    },
    isCurrentGroup(item) {
      return item.namespace?.id === this.groupGid;
    },
    getDeleteButtonTooltipText(item) {
      return this.isCurrentGroup(item)
        ? this.$options.i18n.removeButtonDisabled
        : this.$options.i18n.removeButton;
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
      :fields="tableHeaderFields"
      :items="enabledNamespaces"
      :sort-by.sync="sortBy"
      :sort-desc.sync="sortDesc"
      thead-class="gl-border-t-0 gl-border-b-solid gl-border-b-1 gl-border-b-gray-100"
      stacked="sm"
    >
      <template v-for="header in tableHeaderFields" #[headerSlotName(header.key)]>
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
        <div :data-testid="$options.testids.NAMESPACE">
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

      <template v-for="col in cols" #[cellSlotName(col.key)]="{ item }">
        <devops-adoption-table-cell-flag
          v-if="item.latestSnapshot"
          :key="col.key"
          :data-testid="col.testId"
          :enabled="Boolean(item.latestSnapshot[col.key])"
        />
      </template>

      <template #cell(actions)="{ item }">
        <span
          v-gl-tooltip.hover="getDeleteButtonTooltipText(item)"
          :data-testid="$options.testids.ACTIONS"
        >
          <gl-button
            v-gl-modal="$options.deleteModalId"
            :disabled="isCurrentGroup(item)"
            category="tertiary"
            icon="remove"
            :aria-label="$options.i18n.removeButton"
            @click="setSelectedNamespace(item)"
          />
        </span>
      </template>
    </gl-table>
    <devops-adoption-delete-modal
      v-if="selectedNamespace"
      :namespace="selectedNamespace"
      @enabledNamespacesRemoved="$emit('enabledNamespacesRemoved', $event)"
      @trackModalOpenState="$emit('trackModalOpenState', $event)"
    />
  </div>
</template>
