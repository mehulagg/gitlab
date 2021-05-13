<script>
import { GlTable } from '@gitlab/ui';
import { mapState } from 'vuex';
import { __, s__ } from '~/locale';
import { EMPTY_STATUS_CHECK } from '../constants';
import Actions from './actions.vue';
import Branch from './branch.vue';
import ModalCreate from './modal_create.vue';
import ModalUpdate from './modal_update.vue';

const DEFAULT_TH_CLASSES =
  'gl-bg-transparent! gl-border-b-solid! gl-border-b-gray-100! gl-p-5! gl-border-b-1!';
const thWidthClass = (width) => `gl-w-${width}p ${DEFAULT_TH_CLASSES}`;

export const i18n = {
  apiHeader: __('API'),
  branchHeader: __('Target branch'),
  emptyTableText: s__('StatusCheck|No status checks are defined yet.'),
  nameHeader: s__('StatusCheck|Service name'),
};

export default {
  components: {
    Actions,
    Branch,
    GlTable,
    ModalCreate,
    ModalUpdate,
  },
  data() {
    return {
      statusCheckToUpdate: EMPTY_STATUS_CHECK,
    };
  },
  computed: {
    ...mapState(['statusChecks']),
  },
  methods: {
    openUpdateModal(statusCheck) {
      this.statusCheckToUpdate = statusCheck;
      this.$refs.updateModal.show();
    },
  },
  fields: [
    {
      key: 'name',
      label: i18n.nameHeader,
      thClass: thWidthClass(20),
    },
    {
      key: 'externalUrl',
      label: i18n.apiHeader,
      thClass: thWidthClass(40),
    },
    {
      key: 'protectedBranches',
      label: i18n.branchHeader,
      thClass: thWidthClass(20),
    },
    {
      key: 'actions',
      label: '',
      thClass: DEFAULT_TH_CLASSES,
      tdClass: 'gl-text-right',
    },
  ],
  i18n,
};
</script>

<template>
  <div>
    <gl-table
      :items="statusChecks"
      :fields="$options.fields"
      primary-key="id"
      :empty-text="$options.i18n.emptyTableText"
      show-empty
      stacked="md"
    >
      <template #cell(protectedBranches)="{ item }">
        <branch :branches="item.protectedBranches" />
      </template>
      <template #cell(actions)="{ item }">
        <actions :status-check="item" @update-status-to-check="openUpdateModal" />
      </template>
    </gl-table>

    <modal-create />
    <modal-update ref="updateModal" :status-check="statusCheckToUpdate" />
  </div>
</template>
