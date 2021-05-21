<script>
import { GlButton, GlTable } from '@gitlab/ui';
import { mapState } from 'vuex';
import { DEFAULT_TH_CLASSES } from '~/lib/utils/constants';
import { thWidthClass } from '~/lib/utils/table_utility';
import { __, s__ } from '~/locale';
import Actions from './actions.vue';
import Branch from './branch.vue';

export const i18n = {
  addButton: s__('StatusCheck|Add status check'),
  apiHeader: __('API'),
  branchHeader: __('Target branch'),
  emptyTableText: s__('StatusCheck|No status checks are defined yet.'),
  nameHeader: s__('StatusCheck|Service name'),
};

export default {
  components: {
    Actions,
    Branch,
    GlButton,
    GlTable,
  },
  computed: {
    ...mapState(['statusChecks']),
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
      <template #cell(actions)>
        <actions />
      </template>
    </gl-table>

    <gl-button category="secondary" variant="confirm" size="small">
      {{ $options.i18n.addButton }}
    </gl-button>
  </div>
</template>
