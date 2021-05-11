import { GlToast } from '@gitlab/ui';
import Vue from 'vue';
import Vuex from 'vuex';
import { parseDataAttributes } from '~/members/utils';
import MemberTabs from './components/member_tabs.vue';
import { MEMBER_TYPES } from './constants';
import membersStore from './store';

export const initMembersApp = (el, options) => {
  if (!el) {
    return () => {};
  }

  Vue.use(Vuex);
  Vue.use(GlToast);

  const { sourceId, canManageMembers, ...vuexStoreAttributes } = parseDataAttributes(el);
  const getNamespacedOptions = (namespace) => {
    const {
      tableFields = [],
      tableAttrs = {},
      tableSortableFields = [],
      requestFormatter = () => {},
      filteredSearchBar = { show: false },
    } = options[namespace];

    return { tableFields, tableAttrs, tableSortableFields, requestFormatter, filteredSearchBar };
  };

  const modules = {
    [MEMBER_TYPES.user]: membersStore({
      ...vuexStoreAttributes[MEMBER_TYPES.user],
      ...getNamespacedOptions(MEMBER_TYPES.user),
    }),
    [MEMBER_TYPES.group]: membersStore({
      ...vuexStoreAttributes[MEMBER_TYPES.group],
      ...getNamespacedOptions(MEMBER_TYPES.group),
    }),
    [MEMBER_TYPES.invite]: membersStore({
      ...vuexStoreAttributes[MEMBER_TYPES.invite],
      ...getNamespacedOptions(MEMBER_TYPES.invite),
    }),
    [MEMBER_TYPES.accessRequest]: membersStore({
      ...vuexStoreAttributes[MEMBER_TYPES.accessRequest],
      ...getNamespacedOptions(MEMBER_TYPES.accessRequest),
    }),
  };

  const store = new Vuex.Store({ modules });

  return new Vue({
    el,
    components: { MemberTabs },
    store,
    provide: {
      currentUserId: gon.current_user_id || null,
      sourceId,
      canManageMembers,
    },
    render: (createElement) => createElement('member-tabs'),
  });
};
