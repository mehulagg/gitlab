import Vue from 'vue';
import { parseInt } from 'lodash';
import {
  TABLE_TYPE_DEFAULT,
  TABLE_TYPE_FREE,
  TABLE_TYPE_TRIAL,
  HEADER_TOTAL_ENTRIES,
} from 'ee/billings/constants';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import * as types from './mutation_types';

export default {
  [types.SET_NAMESPACE_ID](state, payload) {
    state.namespaceId = payload;
  },

  [types.REQUEST_SUBSCRIPTION](state) {
    state.isLoadingSubscription = true;
    state.hasErrorSubscription = false;
  },

  [types.RECEIVE_SUBSCRIPTION_SUCCESS](state, payload) {
    const data = convertObjectPropsToCamelCase(payload, { deep: true });
    const { plan, usage, billing } = data;
    let tableKey = TABLE_TYPE_DEFAULT;

    state.plan = plan;

    if (state.plan.code === null) {
      tableKey = TABLE_TYPE_FREE;
    } else if (state.plan.trial) {
      tableKey = TABLE_TYPE_TRIAL;
    }

    state.tables[tableKey].rows.forEach((row) => {
      row.columns.forEach((col) => {
        if (Object.prototype.hasOwnProperty.call(usage, col.id)) {
          Vue.set(col, 'value', usage[col.id]);
        } else if (Object.prototype.hasOwnProperty.call(billing, col.id)) {
          Vue.set(col, 'value', billing[col.id]);
        }
      });
    });

    state.isLoadingSubscription = false;
  },

  [types.RECEIVE_SUBSCRIPTION_ERROR](state) {
    state.isLoadingSubscription = false;
    state.hasErrorSubscription = true;
  },

  [types.REQUEST_HAS_BILLABLE_MEMBERS](state) {
    state.isLoadingHasBillableMembers = true;
    state.hasErrorHasBillableMembers = false;
  },

  [types.RECEIVE_HAS_BILLABLE_MEMBERS_SUCCESS](state, payload) {
    const { headers } = payload;
    const hasBillableGroupMembers = parseInt(headers[HEADER_TOTAL_ENTRIES], 10) > 0;

    state.hasBillableGroupMembers = hasBillableGroupMembers;
    state.isLoadingHasBillableMembers = false;
  },

  [types.RECEIVE_HAS_BILLABLE_MEMBERS_ERROR](state) {
    state.isLoadinggHasBillableMembers = false;
    state.hasErrorHasBillableMembers = true;
  },
};
